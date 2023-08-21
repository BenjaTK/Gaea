@tool
class_name ChunkAwareModifier
extends Modifier


func apply(grid: Dictionary, _generator: GaeaGenerator) -> Dictionary:
	return _apply_area(
		GaeaGenerator.get_area_from_grid(grid),
		grid,
		_generator
	)


func apply_chunk(grid: Dictionary, _generator: GaeaGenerator, chunk_position: Vector2i) -> Dictionary:
	return _apply_area(
		Rect2i(
			chunk_position * GaeaGenerator.CHUNK_SIZE,
			Vector2i(GaeaGenerator.CHUNK_SIZE, GaeaGenerator.CHUNK_SIZE)
		),
		grid,
		_generator
	)


func _apply_area(area: Rect2i, grid: Dictionary, _generator: GaeaGenerator) -> Dictionary:
	push_warning("%s doesn't have a `_apply_area` implementation" % resource_name)
	return {}
