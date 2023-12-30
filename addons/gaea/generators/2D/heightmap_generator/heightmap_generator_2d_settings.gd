class_name HeightmapGenerator2DSettings
extends GeneratorSettings2D

## Info for the tile that will be placed. Has information about
## it's position in the TileSet.
@export var tile: TileInfo
@export var noise: FastNoiseLite = FastNoiseLite.new()
## Infinite worlds only work with a [ChunkLoader2D].
@export var infinite := false
@export var world_length := 128
## The medium height at which the heightmap will start displacing from y=0.
## The heightmap displaces this height by a random number
## between -[param height_intensity] and [param height_intensity].
@export var height_offset := 128
## The heightmap displaces [param height_offset] by a random number
## from -[param height_intensity] to [param height_intensity].
@export var height_intensity := 20
## Negative values means the HeightmapGenerator will go below y=0.
@export var min_height := 0
