@tool
@icon("carver.svg")
class_name Carver
extends ChunkAwareModifier2D
## Uses noise to remove certain tiles from the map.
##@tutorial(Carver Modifier): https://benjatk.github.io/Gaea/#/modifiers?id=-carver


@export var noise: FastNoiseLite = FastNoiseLite.new()
@export var random_noise_seed := true
## Any values in the noise texture that go above this threshold
## will be deleted from the map. (-1.0 is black, 1.0 is white)[br]
## Lower values mean more empty areas.
@export_range(-1.0, 1.0) var threshold := 0.15
@export_group("Bounds")
## Leave any or both axis as [code]inf[/code] to not have any limits.
@export var max := Vector2(INF, INF)
## Leave any or both axis as [code]-inf[/code] to not have any limits.
@export var min := Vector2(-INF, -INF)


func _apply_area(area: Rect2i, grid: GaeaGrid, _generator: GaeaGenerator) -> void:
	for x in range(area.position.x, area.end.x + 1):
		for y in range(area.position.y, area.end.y + 1):
			var cell := Vector2i(x, y)
			if not grid.has_cell(cell) or _is_out_of_bounds(cell):
				continue

			if not _passes_filter(grid.get_value(cell)):
				continue

			if noise.get_noise_2d(cell.x, cell.y) > threshold:
				grid.erase(cell)


func _is_out_of_bounds(cell: Vector2i) -> bool:
	return (cell.x > max.x or cell.y > max.y or
			cell.x < min.x or cell.y < min.y)
