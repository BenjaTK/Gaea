@tool
class_name NoiseGeneratorData
extends Resource
## Data for [NoiseGenerator]s, it contains a [param threshold] and a [param tile] of the class [TileInfo], also a [param title] for easier identification.

@export var title: String = "":
	set(value):
		title = value
		resource_name = title

@export_range(-1.0, 1.0) var threshold: float
@export var tile: TileInfo = TileInfo.new()
