@tool
@icon("noise_painter.svg")
class_name NoisePainter3D
extends ChunkAwareModifier3D
## Replaces the tiles in the map with [param tile] based on a noise texture.
##
## Useful for placing ores or decorations.
## @tutorial(Noise Painter Modifier): https://benjatk.github.io/Gaea/#/modifiers?id=-noise-painter


enum NoiseMode {
	NOISE_2D, ## Ignores the y axis and sets all the tiles in the columns that go above [param threshold]
	NOISE_3D ## Doesn't ignore the y axis.
	}

@export var noise: FastNoiseLite = FastNoiseLite.new()
@export var noise_mode: NoiseMode = NoiseMode.NOISE_2D
@export var random_noise_seed := true
@export var tile: TileInfo
## Any values in the noise texture that go above this threshold
## will be replaced with [param tile]. (-1.0 is black, 1.0 is white)
@export_range(-1.0, 1.0) var threshold: float = 0.6
@export_group("Bounds")
## Leave any or both axis as [code]inf[/code] to not have any limits.
@export var max := Vector3(INF, INF, INF)
## Leave any or both axis as [code]-inf[/code] to not have any limits.
@export var min := Vector3(-INF, -INF, -INF)


func _apply_area(area: AABB, grid: Dictionary, _generator: GaeaGenerator) -> Dictionary:
	for x in range(area.position.x, area.end.x + 1):
		for y in range(area.position.y, area.end.y + 1):
			for z in range(area.position.z, area.end.z + 1):
				var tile_pos := Vector3(x, y, z)
				var noise_pos := Vector3(x, 0, z)
				if noise_mode == NoiseMode.NOISE_3D: #3D
					noise_pos.y = y

				if not grid.has_cell(tile_pos) or _is_out_of_bounds(tile_pos):
					continue

				if noise.get_noise_3dv(noise_pos) > threshold:
					if not _passes_filter(grid[tile_pos]):
						continue

					grid[tile_pos] = tile

	return grid


func _is_out_of_bounds(tile_pos: Vector3) -> bool:
	return (tile_pos.x > max.x or tile_pos.y > max.y or tile_pos.z > max.z or
			tile_pos.x < min.x or tile_pos.y < min.y or tile_pos.z < min.z)
