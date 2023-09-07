@tool
@icon("smooth.svg")
class_name Smooth
extends Modifier
## Applies a smoothing algorithm to all tiles using Cellular Automata.
## @tutorial(Smooth Modifier): https://benjatk.github.io/Gaea/#/modifiers?id=-smooth


## The amount of iterations the smoothing algorithm will do. Higher values lead to
## smoother terrain.[br][br]
## [b]Note[/b]: High values can lead to empty terrain, disconnected paths,
## or more problems.
@export var iterations := 2
## The smoothing algorithm checks every tile and, if it
## has more empty neighbors than [param maximum_empty_neighbors],
## it deletes it. Decreasing this value will increase the smoothness.[br][br]
## [b]Note[/b]: Low values can lead to empty terrain, disconnected paths,
## or more problems.
@export_range(1, 7) var maximum_empty_neighbors := 4


func apply(grid: Dictionary, _generator: GaeaGenerator) -> Dictionary:
	for i in iterations:
		for tile in grid.keys():
			var empty_neighbors_count := GaeaGenerator.get_neighbor_count_of_type(
				grid, tile, null
			)
			if empty_neighbors_count > maximum_empty_neighbors:
				grid.erase(tile)
	return grid
