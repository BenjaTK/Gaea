@tool
@icon("chunk_aware_generator.svg")
class_name ChunkAwareGenerator
extends GaeaGenerator

## The size of the Chunks. [br]
## [b]Warning: Cannot be set to 0[/b]
@export var chunk_size: int = 16

var generated_chunks: Array[Vector2i] = []

func _ready() -> void:
	if chunk_size == 0:
		push_error("Chunk Size can not be 0!")

	super._ready()


func generate_chunk(chunk_position: Vector2i) -> void:
	if not is_instance_valid(tile_map):
		push_error("%s doesn't have a TileMap" % name)
		return


func erase_chunk(chunk_position: Vector2i, clear_tilemap := true) -> void:
	for x in get_chunk_range(chunk_position.x):
		for y in get_chunk_range(chunk_position.y):
			grid.erase(Vector2(x, y))

			if not clear_tilemap: continue
			for l in range(tile_map.get_layers_count()):
				tile_map.erase_cell(l, Vector2(x, y))


func _apply_modifiers_chunk(modifiers: Array[Modifier], chunk_position: Vector2i) -> void:
	for modifier in modifiers:
		if not (modifier is ChunkAwareModifier):
			push_error("%s is not a Chunk compatible modifier!" % modifier.resource_name)
			continue

		grid = modifier.apply_chunk(grid, self, chunk_position)


func _draw_tiles_chunk(chunk_position: Vector2i) -> void:
	_draw_tiles_area(Rect2i(chunk_position * chunk_size, Vector2i(chunk_size, chunk_size)))


func unload_chunk(chunk_position: Vector2i) -> void:
	erase_chunk(chunk_position)
	generated_chunks.erase(chunk_position)


### Utils ###

func has_chunk(chunk_position: Vector2i) -> bool:
	return generated_chunks.has(chunk_position)


func get_chunk_range(position: int) -> Array:
	return range(
		position * chunk_size,
		(position + 1) * chunk_size,
		1
	)
