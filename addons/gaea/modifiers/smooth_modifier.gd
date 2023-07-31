@tool
@icon("smooth_modifier.svg")
class_name Smooth extends Modifier
## Applies a smoothing algorithm to all tiles using Cellular Automata.


## The amount of iterations the smoothing algorithm will do. Higher values lead to
## smoother terrain.[br][br]
## [b]Note[/b]: High values can lead to empty terrain, disconnected paths,
## or more problems.
@export var iterations := 2
## The smoothing algorithm checks every tile and, if it
## has more empty neighbors than [param maximumEmptyNeighbors],
## it deletes it. Decreasing this value will increase the smoothness.[br][br]
## [b]Note[/b]: Low values can lead to empty terrain, disconnected paths,
## or more problems.
@export_range(1, 7) var maximumEmptyNeighbors := 4


func apply(grid: Dictionary, generator: GaeaGenerator) -> Dictionary:
	for i in iterations:
		for tile in grid.keys():
			var emptyNeighborsCount := GaeaGenerator.get_neighbor_count_of_type(
				grid, tile, null
			)
			if emptyNeighborsCount > maximumEmptyNeighbors:
				grid.erase(tile)
	return grid
