class_name HeightmapGenerator2DSettings extends GeneratorSettings


## The seed doesn't matter as it will get randomly generated.
@export var noise: FastNoiseLite = FastNoiseLite.new()
@export var randomNoiseSeed := true
@export var worldLength := 128
## The medium height at which the heightmap will start displacing.
## The heightmap displaces this height by a random number
## between -[param heightIntensity] and [param heightIntensity].
@export var heightOffset := 128
## The heightmap displaces [param heightOffset] by a random number
## from -[param heightIntensity] to [param heightIntensity].
@export var heightIntensity := 20
