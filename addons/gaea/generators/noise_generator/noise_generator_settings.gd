@tool
class_name NoiseGeneratorSettings extends GeneratorSettings


## Dictionary of thresholds (keys) that go from -1.0 to 1.0 and TileInfo (values).[br]
## The algorithm loops through all thresholds and, if the noise value
## at the coordinate is higher than it,
## it places the configured tile.[br][br]
## [b]Note:[/b] The order of the Dictionary matters. It HAS to be in order of
## highest threshold to lowest threshold.
@export var tiles : Dictionary
@export var noise: FastNoiseLite = FastNoiseLite.new()
@export var randomNoiseSeed := true
@export var worldSize: Vector2i = Vector2i(256, 256)
