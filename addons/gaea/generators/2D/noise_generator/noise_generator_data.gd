@tool
class_name NoiseGeneratorData
extends Resource
## Data for [NoiseGenerator]s, it contains a [param threshold] and a [param tile] of the class [TileInfo], also a [param title] for easier identification.

## [param title] will rename the resource when it changes
@export var title: String = "":
	set(value):
		title = value
		resource_name = title
## [param threshold] if the threshold is higher than 
## the noise it will place the [param tile] there
@export_range(-1.0, 1.0) var threshold: float
## The tile to place
@export var tile: TileInfo = TileInfo.new()
