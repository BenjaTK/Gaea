@tool
@icon("noise_painter.svg")
class_name NoisePainter
extends Modifier
## Replaces the tiles in the map with [param tile] based on a noise texture.
##
## Useful for placing ores or decorations.


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


func apply(grid: Dictionary, _generator: GaeaGenerator) -> Dictionary:
	if random_noise_seed:
		noise.seed = randi()

	for tile_pos in grid.keys():
		if _is_out_of_bounds(tile_pos):
			continue

		if noise.get_noise_2dv(tile_pos) > threshold:
			grid[tile_pos] = tile
	return grid


func _is_out_of_bounds(tile_pos: Vector2) -> bool:
	return (tile_pos.x > max.x or tile_pos.y > max.y or
			tile_pos.x < min.x or tile_pos.y < min.y)
