extends Resource
class_name NoiseGeneratorData
##Intended only for organizing
@export var title: String
@export_range(-1.0, 1.0) var threshold: float
@export var tile: TileInfo = TileInfo.new()
