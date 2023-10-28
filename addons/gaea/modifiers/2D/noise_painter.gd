@tool
@icon("noise_painter.svg")
class_name NoisePainter
extends ChunkAwareModifier2D
## Replaces the tiles in the map with [param tile] based on a noise texture.
##
## Useful for placing ores or decorations.
## @tutorial(Noise Painter Modifier): https://benjatk.github.io/Gaea/#/modifiers?id=-noise-painter


@export var noise: FastNoiseLite = FastNoiseLite.new()
@export var random_noise_seed := true
@export var tile: TileInfo
## Any values in the noise texture that go above this threshold
## will be replaced with [param tile]. (-1.0 is black, 1.0 is white)
@export_range(-1.0, 1.0) var threshold: float = 0.6
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


			if noise.get_noise_2dv(cell) > threshold:
				if not _passes_filter(grid.get_value(cell)):
					continue

				grid.set_value(cell, tile)


func _is_out_of_bounds(cell: Vector2i) -> bool:
	return (cell.x > max.x or cell.y > max.y or
			cell.x < min.x or cell.y < min.y)
