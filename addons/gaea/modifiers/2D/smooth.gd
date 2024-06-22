@tool
@icon("smooth.svg")
class_name Smooth
extends Modifier2D
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


func apply(grid: GaeaGrid, generator: GaeaGenerator):
	for i in iterations:
		for layer in affected_layers:
			for cell in grid.get_cells(layer):
				if not _passes_filter(grid, cell):
					continue

				var empty_neighbors_count: int = grid.get_amount_of_empty_neighbors(cell, layer)

				if empty_neighbors_count > maximum_empty_neighbors:
					grid.erase(cell, layer)
