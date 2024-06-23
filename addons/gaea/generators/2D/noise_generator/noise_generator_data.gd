@tool
class_name NoiseGeneratorData
extends Resource
## Data for [NoiseGenerator]s, it contains a [param threshold] and a [param tile] of the class [TileInfo], also a [param title] for easier identification.

## The name of this resource
@export var title: String = "":
	set(value):
		title = value
		resource_name = title
## The tile to place
@export var tile: TileInfo
## To allow for a range of thresholds
## Also min and max have a setter that prevents min from being greater than max and vice versa
@export_group("Thresholds")
# Note: i just dont want to call them threshold_min and threshold_max, it seems repetitive for me
## The minimum threshold
@export_range(-1.0, 1.0) var min: float = -1.0:
	set(value):
		min = value
		if min > max:
			max = min
		emit_changed()
## The maximum threshold
@export_range(-1.0, 1.0) var max: float = 1.0:
	set(value):
		max = value
		if max < min:
			min = max
		emit_changed()

var settings: NoiseGeneratorSettings:
	set(value):
		settings = value
		settings.noise.changed.connect(emit_changed)
