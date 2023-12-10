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
@export var affected_layers: Array[int]
@export_group("Bounds", "bounds_")
@export var bounds_enabled: bool = false
@export var bounds_max := Vector2(0, 0)
@export var bounds_min := Vector2(-0, -0)


func _apply_area(area: Rect2i, grid: GaeaGrid, _generator: GaeaGenerator) -> void:
	for x in range(area.position.x, area.end.x + 1):
		for y in range(area.position.y, area.end.y + 1):
			var cell := Vector2i(x, y)
			for layer in affected_layers:
				if not grid.has_cell(cell, layer) or _is_out_of_bounds(cell):
					continue


				if noise.get_noise_2dv(cell) > threshold:
					if not _passes_filter(grid.get_value(cell, layer)):
						continue

					grid.set_value(cell, tile)


func _is_out_of_bounds(cell: Vector2i) -> bool:
	if not bounds_enabled:
		return false

	return (cell.x > bounds_max.x or cell.y > bounds_max.y or
			cell.x < bounds_min.x or cell.y < bounds_min.y)
