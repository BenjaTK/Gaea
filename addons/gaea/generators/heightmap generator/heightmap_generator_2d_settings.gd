class_name HeightmapGenerator2DSettings extends GeneratorSettings


## The seed doesn't matter as it will get randomly generated.
@export var noise: FastNoiseLite
@export var worldSize: Vector2i = Vector2i(16, 256)
## The medium height at which the heightmap will start displacing.
## The heightmap displaces this height by a random number
## from -[param heightIntensity] to [param heightIntensity].
@export var heightOffset := 60
## The heightmap displaces [param heightOffset] by a random number
## from -[param heightIntensity] to [param heightIntensity].
@export var heightIntensity := 5
