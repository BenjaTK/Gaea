@tool
@icon("../2D/carver.svg")
class_name Carver3D
extends ChunkAwareModifier3D
## Uses noise to remove certain tiles from the map.
##@tutorial(Carver Modifier): https://benjatk.github.io/Gaea/#/modifiers?id=-carver

@export var noise: FastNoiseLite = FastNoiseLite.new():
	set(value):
		noise = value
		if is_instance_valid(noise):
			noise.changed.connect(emit_changed)
		emit_changed()
@export_group("Threshold")
## The minimum threshold. Any values in the noise that are between [param min] and [param max] (inclusive)
## will be deleted. (-1.0 is black, 1.0 is white)
@export_range(-1.0, 1.0) var min: float = -1.0:
	set(value):
		min = value
		if min > max:
			max = min
		emit_changed()
## The maximum threshold. Any values in the noise that are between [param min] and [param max] (inclusive)
## will be deleted. (-1.0 is black, 1.0 is white)
@export_range(-1.0, 1.0) var max: float = 1.0:
	set(value):
		max = value
		if max < min:
			min = max
		emit_changed()
@export_group("Bounds", "bounds_")
@export var bounds_enabled := false
@export var bounds_max := Vector3(0, 0, 0)
@export var bounds_min := Vector3(-0, -0, -0)


func _apply_area(area: AABB, grid: GaeaGrid, _generator: GaeaGenerator) -> void:
	for x in range(area.position.x, area.end.x + 1):
		for y in range(area.position.y, area.end.y + 1):
			for z in range(area.position.z, area.end.z + 1):
				for layer in affected_layers:
					var cell := Vector3i(x, y, z)
					if not grid.has_cell(cell, layer) or _is_out_of_bounds(cell):
						continue

					if not _passes_filter(grid, cell):
						continue

					var value: float = noise.get_noise_3dv(cell)
					if value >= min and value <= max:
						grid.erase(cell, layer)


func _is_out_of_bounds(cell: Vector3i) -> bool:
	if not bounds_enabled:
		return false

	return (
		cell.x > bounds_max.x or cell.x < bounds_min.x
		or cell.y > bounds_max.y or cell.y < bounds_min.y
		or cell.z > bounds_max.z or cell.z < bounds_min.z
	)
