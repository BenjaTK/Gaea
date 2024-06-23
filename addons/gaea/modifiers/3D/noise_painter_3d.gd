@tool
@icon("noise_painter.svg")
class_name NoisePainter3D
extends ChunkAwareModifier3D
## Replaces the tiles in the map with [param tile] based on a noise texture.
##
## Useful for placing ores or decorations.
## @tutorial(Noise Painter Modifier): https://benjatk.github.io/Gaea/#/modifiers?id=-noise-painter

enum NoiseMode { NOISE_2D, NOISE_3D }  ## Ignores the y axis and sets all the tiles in the columns that go above [param threshold]  ## Doesn't ignore the y axis.

@export var noise: FastNoiseLite = FastNoiseLite.new():
	set(value):
		noise = value
		if is_instance_valid(noise):
			noise.changed.connect(emit_changed)
		emit_changed()
@export var ignore_empty_cells: bool = true
@export var noise_mode: NoiseMode = NoiseMode.NOISE_2D
@export var tile: TileInfo
@export_group("Threshold")
## The minimum threshold. Any values in the noise that are between [param min] and [param max] (inclusive)
## will be replaced with [param tile]. (-1.0 is black, 1.0 is white)
@export_range(-1.0, 1.0) var min: float = -1.0:
	set(value):
		min = value
		if min > max:
			max = min
		emit_changed()
## The maximum threshold. Any values in the noise that are between [param min] and [param max] (inclusive)
## will be replaced with [param tile]. (-1.0 is black, 1.0 is white)
@export_range(-1.0, 1.0) var max: float = 1.0:
	set(value):
		max = value
		if max < min:
			min = max
		emit_changed()
@export_group("Bounds", "bounds_")
@export var bounds_enabled := false
## Leave any or both axis as [code]inf[/code] to not have any limits.
@export var bounds_max := Vector3(INF, INF, INF)
## Leave any or both axis as [code]-inf[/code] to not have any limits.
@export var bounds_min := Vector3(-INF, -INF, -INF)


func _apply_area(area: AABB, grid: GaeaGrid, _generator: GaeaGenerator) -> void:
	for x in range(area.position.x, area.end.x + 1):
		for y in range(area.position.y, area.end.y + 1):
			for z in range(area.position.z, area.end.z + 1):
				var cell := Vector3i(x, y, z)
				var noise_pos := Vector3(x, 0, z)
				if noise_mode == NoiseMode.NOISE_3D:  #3D
					noise_pos.y = y

				if not grid.has_cell(cell, tile.layer) and ignore_empty_cells or _is_out_of_bounds(cell):
					continue

				var value: float = noise.get_noise_3dv(noise_pos)
				if value >= min and value <= max:
					if not _passes_filter(grid, cell):
						continue

					grid.set_value(cell, tile)


func _is_out_of_bounds(cell: Vector3i) -> bool:
	if not bounds_enabled:
		return false

	return (
		cell.x > bounds_max.x or cell.x < bounds_min.x
		or cell.y > bounds_max.y or cell.y < bounds_min.y
		or cell.z > bounds_max.z or cell.z < bounds_min.z
	)


func _validate_property(property: Dictionary) -> void:
	super(property)
	if property.name == "affected_layers":
		property.usage = PROPERTY_USAGE_NONE
