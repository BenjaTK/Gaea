@tool
@icon("../2D/carver.svg")
class_name Carver3D
extends ChunkAwareModifier3D
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
@export var max := Vector3(INF, INF, INF)
## Leave any or both axis as [code]-inf[/code] to not have any limits.
@export var min := Vector3(-INF, -INF, -INF)


func _apply_area(area: AABB, grid: Dictionary, _generator: GaeaGenerator) -> Dictionary:
	for x in range(area.position.x, area.end.x + 1):
		for y in range(area.position.y, area.end.y + 1):
			for z in range(area.position.x, area.end.z + 1):
				var tile_pos := Vector3(x, y, z)
				if not grid.has(tile_pos) or _is_out_of_bounds(tile_pos):
					continue

				if not _passes_filter(grid[tile_pos]):
					continue

				if noise.get_noise_3dv(tile_pos) > threshold:
					grid.erase(tile_pos)

	return grid


func _is_out_of_bounds(tile_pos: Vector3) -> bool:
	return (tile_pos.x > max.x or tile_pos.y > max.y or tile_pos.z > max.z or
			tile_pos.x < min.x or tile_pos.y < min.y or tile_pos.z < min.z)
