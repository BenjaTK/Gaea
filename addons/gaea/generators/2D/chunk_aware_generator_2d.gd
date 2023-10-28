@tool
@icon("../chunk_aware_generator.svg")
class_name ChunkAwareGenerator2D
extends GaeaGenerator2D


signal chunk_updated(chunk_position: Vector2i)


## The size of the Chunks. [br]
## [b]Warning: Cannot be set to 0[/b]
@export var chunk_size: int = 16

var generated_chunks: Array[Vector2i] = []


func _ready() -> void:
	if chunk_size == 0:
		push_error("Chunk Size can not be 0!")

	super._ready()


func generate_chunk(chunk_position: Vector2i, starting_grid: GaeaGrid = null) -> void:
	push_warning("generate_chunk method not overriden at %s" % name)


func erase_chunk(chunk_position: Vector2i) -> void:
	for x in get_chunk_range(chunk_position.x):
		for y in get_chunk_range(chunk_position.y):
			grid.erase(Vector2i(x, y))

	chunk_updated.emit(chunk_position)



func _apply_modifiers_chunk(modifiers: Array[Modifier2D], chunk_position: Vector2i) -> void:
	for modifier in modifiers:
		if not (modifier is ChunkAwareModifier2D):
			push_error("%s is not a Chunk compatible modifier!" % modifier.resource_name)
			continue

		modifier.apply_chunk(grid, self, chunk_position)


func unload_chunk(chunk_position: Vector2i) -> void:
	erase_chunk(chunk_position)
	generated_chunks.erase(chunk_position)

	if is_instance_valid(next_pass) and next_pass is ChunkAwareGenerator2D:
		next_pass.unload_chunk(chunk_position)
		return


### Utils ###

func has_chunk(chunk_position: Vector2i) -> bool:
	return generated_chunks.has(chunk_position)


func get_chunk_range(position: int) -> Array:
	return range(
		position * chunk_size,
		(position + 1) * chunk_size,
		1
	)
