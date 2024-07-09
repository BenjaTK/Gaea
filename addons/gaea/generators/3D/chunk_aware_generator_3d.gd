@tool
@icon("../chunk_aware_generator.svg")
class_name ChunkAwareGenerator3D
extends GaeaGenerator3D
## @tutorial(Chunk Generation): https://benjatk.github.io/Gaea/#/tutorials/chunk_generation

## Emitted when any update to a chunk is made. Either erasing it or generating it.
signal chunk_updated(chunk_position: Vector3i)
## Emitted when a chunk is finished generated. [signal chunk_updated] is also called.
signal chunk_generation_finished(chunk_position: Vector3i)
## Emitted when a chunk is erased. [signal chunk_updated] is also called.
signal chunk_erased(chunk_position: Vector3i)

## The size of the Chunks. [br]
## [b]Warning: Cannot be set to 0[/b]
@export var chunk_size: Vector3i = Vector3i(16, 16, 16)

var generated_chunks: Array[Vector3i] = []


func _ready() -> void:
	if chunk_size.x <= 0 or chunk_size.y <= 0 or chunk_size.z <= 0:
		push_error("Chunk Size can not be 0!")

	super._ready()


func generate_chunk(chunk_position: Vector3i, starting_grid: GaeaGrid = null) -> void:
	push_warning("generate_chunk method not overriden at %s" % name)


func erase_chunk(chunk_position: Vector3i) -> void:
	for x in get_chunk_axis_range(chunk_position.x, chunk_size.x):
		for y in get_chunk_axis_range(chunk_position.y, chunk_size.y):
			for z in get_chunk_axis_range(chunk_position.z, chunk_size.z):
				for layer in range(grid.get_layer_count()):
					grid.erase(Vector3i(x, y, z), layer)

	(func(): chunk_updated.emit(chunk_position)).call_deferred()  # deferred for threadability
	(func(): chunk_erased.emit(chunk_position)).call_deferred()  # deferred for threadability


func _apply_modifiers_chunk(modifiers, chunk_position: Vector3i) -> void:
	for modifier in modifiers:
		if not modifier is ChunkAwareModifier3D:
			push_error("%s is not a Chunk compatible modifier!" % modifier.resource_name)
			continue

		if not modifier.enabled:
			continue

		modifier.apply_chunk(grid, self, chunk_position)


func unload_chunk(chunk_position: Vector3i) -> void:
	erase_chunk(chunk_position)
	generated_chunks.erase(chunk_position)


### Utils ###


func has_chunk(chunk_position: Vector3i) -> bool:
	return generated_chunks.has(chunk_position)


## Returns the range (see [method range]) of the axis of [param axis_size] of the chunk at [param position] in that axis.
func get_chunk_axis_range(position: int, axis_size: int) -> Array:
	return range(position * axis_size, (position + 1) * axis_size, 1)


## Returns the coordinates of the chunk containing the cell at the given [param map_position].
func map_to_chunk(map_position: Vector3i) -> Vector3i:
	return Vector3i(
		floori(float(map_position.x) / chunk_size.x),
		floori(float(map_position.y) / chunk_size.y),
		floori(float(map_position.z) / chunk_size.z)
	)
