class_name HeightmapGenerator2DSettings
extends GeneratorSettings

## Info for the tile that will be placed. Has information about
## it's position in the TileSet.
@export var tile: TileInfo
@export var noise: FastNoiseLite = FastNoiseLite.new()
@export var random_noise_seed := true
@export var world_length := 128
## The medium height at which the heightmap will start displacing.
## The heightmap displaces this height by a random number
## between -[param height_intensity] and [param height_intensity].
@export var height_offset := 128
## The heightmap displaces [param height_offset] by a random number
## from -[param height_intensity] to [param height_intensity].
@export var height_intensity := 20