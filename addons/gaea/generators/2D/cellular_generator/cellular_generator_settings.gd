@tool
class_name CellularGeneratorSettings
extends GeneratorSettings2D

## [TileInfo] for the tile that will be placed. Has information about
## it's position in the TileSet.
@export var tile: TileInfo
## The generation's size in tiles.
@export var world_size: Vector2i = Vector2i(64, 64)
## The percentage of empty tiles the generator will start with.
## High values can lead to empty maps.
@export_range(0.0, 1.0) var noise_density := 0.5
## The amount of iterations the smoothing algorithm will do. Higher values lead to
## smoother terrain.[br][br]
@export var smooth_iterations := 6
@export_group("Conditions")
## In the smoothing algorithm, if a floor tile has more empty
## neighbor tiles than [param max_floor_empty_neighbors], it will be removed.[br]
## Higher values means more floor, lower values can lead to empty maps.
@export_range(0, 8) var max_floor_empty_neighbors := 4
## In the smoothing algorithm, if an empty tile has less empty neighbor
## tiles than [param min_empty_neighbors], it will become a floor.[br]
## Lower values means more empty tiles.
@export_range(0, 8) var min_empty_neighbors := 3
