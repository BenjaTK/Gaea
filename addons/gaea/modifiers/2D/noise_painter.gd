@tool
@icon("noise_painter.svg")
class_name NoisePainter
extends ChunkAwareModifier2D
## Replaces the tiles in the map with [param tile] based on a noise texture.
##
## Useful for placing ores or decorations.
## @tutorial(Noise Painter Modifier): https://benjatk.github.io/Gaea/#/modifiers?id=-noise-painter

@export var noise: FastNoiseLite = FastNoiseLite.new():
	set(value):
		noise = value
		if is_instance_valid(noise):
			noise.changed.connect(emit_changed)
		emit_changed()
@export var ignore_empty_cells: bool = true
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
@export var bounds_enabled: bool = false
@export var bounds_max := Vector2(0, 0)
@export var bounds_min := Vector2(-0, -0)


func _apply_area(area: Rect2i, grid: GaeaGrid, _generator: GaeaGenerator) -> void:
	for x in range(area.position.x, area.end.x + 1):
		for y in range(area.position.y, area.end.y + 1):
			var cell := Vector2i(x, y)
			if not grid.has_cell(cell, tile.layer) and ignore_empty_cells or _is_out_of_bounds(cell):
				continue

			var value: float = noise.get_noise_2dv(cell)
			if value >= min and value <= max:
				if not _passes_filter(grid, cell):
					continue

				grid.set_value(cell, tile)


func _is_out_of_bounds(cell: Vector2i) -> bool:
	if not bounds_enabled:
		return false

	return cell.x > bounds_max.x or cell.y > bounds_max.y or cell.x < bounds_min.x or cell.y < bounds_min.y


func _validate_property(property: Dictionary) -> void:
	super(property)
	if property.name == "affected_layers":
		property.usage = PROPERTY_USAGE_NONE
