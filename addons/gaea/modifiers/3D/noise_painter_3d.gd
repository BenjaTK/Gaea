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

@export var noise: FastNoiseLite = FastNoiseLite.new() :
	set(value):
		noise = value
		if is_instance_valid(noise):
			noise.changed.connect(emit_changed)
		emit_changed()
@export var ignore_empty_cells: bool = true
@export var noise_mode: NoiseMode = NoiseMode.NOISE_2D
@export var tile: TileInfo
## Any values in the noise texture that go above this threshold
## will be replaced with [param tile]. (-1.0 is black, 1.0 is white)
@export_range(-1.0, 1.0) var threshold: float = 0.6 :
	set(value):
		threshold = value
		emit_changed()
@export_group("Bounds")
## Leave any or both axis as [code]inf[/code] to not have any limits.
@export var max := Vector3(INF, INF, INF)
## Leave any or both axis as [code]-inf[/code] to not have any limits.
@export var min := Vector3(-INF, -INF, -INF)


func _apply_area(area: AABB, grid: GaeaGrid, _generator: GaeaGenerator) -> void:
	for x in range(area.position.x, area.end.x + 1):
		for y in range(area.position.y, area.end.y + 1):
			for z in range(area.position.z, area.end.z + 1):
				var cell := Vector3i(x, y, z)
				var noise_pos := Vector3(x, 0, z)
				if noise_mode == NoiseMode.NOISE_3D: #3D
					noise_pos.y = y

				if not grid.has_cell(cell, tile.layer) and ignore_empty_cells or _is_out_of_bounds(cell):
					continue

				if noise.get_noise_3dv(noise_pos) > threshold:
					if not _passes_filter(grid, cell):
						continue

					grid.set_value(cell, tile)


func _is_out_of_bounds(cell: Vector3i) -> bool:
	return (cell.x > max.x or cell.y > max.y or cell.z > max.z or
			cell.x < min.x or cell.y < min.y or cell.z < min.z)


func _validate_property(property: Dictionary) -> void:
	super(property)
	if property.name == "affected_layers":
		property.usage = PROPERTY_USAGE_NONE
