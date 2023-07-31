@tool
class_name CellularGeneratorSettings extends GeneratorSettings


## The generation's size in tiles.
@export var worldSize: Vector2i = Vector2i(50, 50)
## The percentage of empty tiles the generator will start with.
## High values can lead to empty maps.
@export_range(0.0, 1.0) var noiseDensity := 0.5
## The amount of iterations the smoothing algorithm will do. Higher values lead to
## smoother terrain.[br][br]
@export var smoothIterations := 6
@export_group("Rules")
## In the smoothing algorithm, if a floor tile has more empty
## neighbor tiles than [param maxFloorNeighbors], it will be removed.[br]
## Higher values means more floor, lower values can lead to empty maps.
@export_range(0, 8) var maxFloorEmptyNeighbors := 4
## In the smoothing algorithm, if an empty tile has less empty neighbor
## tiles than [param minEmptyNeighbors], it will become a floor.[br]
## Lower values means more empty tiles.
@export_range(0, 8) var minEmptyNeighbors := 3
