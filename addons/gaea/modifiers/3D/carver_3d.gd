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


func _apply_area(area: AABB, grid: GaeaGrid, _generator: GaeaGenerator) -> void:
	for x in range(area.position.x, area.end.x + 1):
		for y in range(area.position.y, area.end.y + 1):
			for z in range(area.position.x, area.end.z + 1):
				var cell := Vector3i(x, y, z)
				if not grid.has_cell(cell) or _is_out_of_bounds(cell):
					continue

				if not _passes_filter(grid.get_value(cell)):
					continue

				if noise.get_noise_3dv(cell) > threshold:
					grid.erase(cell)


func _is_out_of_bounds(cell: Vector3i) -> bool:
	return (cell.x > max.x or cell.y > max.y or cell.z > max.z or
			cell.x < min.x or cell.y < min.y or cell.z < min.z)
