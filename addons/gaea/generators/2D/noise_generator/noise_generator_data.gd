@tool
class_name NoiseGeneratorData
extends Resource
## Data for [NoiseGenerator]s, it contains a [param threshold] and a [param tile] of the class [TileInfo], also a [param title] for easier identification.

## [param title] the name of this resource
@export var title: String = "":
	set(value):
		title = value
		resource_name = title

## The tile to place
@export var tile: TileInfo 


## To allow for a range of thresholds
## Also threshold_min and threshold_max have a setter that prevents threshold_min from being greater than threshold_max and vice versa
@export_group("Thresholds", "threshold_")
## The minimum threshold
@export_range(-1.0, 1.0) var threshold_min: float = -1.0 : 
	set(value):
		threshold_min = value
		if threshold_min > threshold_max:
			threshold_max = threshold_min

## The maximum threshold
@export_range(-1.0, 1.0) var threshold_max: float = 1.0 : 
	set(value):
		threshold_max = value
		if threshold_max < threshold_min:
			threshold_min = threshold_max


