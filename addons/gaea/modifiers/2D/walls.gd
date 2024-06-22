@tool
@icon("walls.svg")
class_name Walls
extends Modifier2D
## Adds [param wall_tile] below any tile that isn't the Generator's default tile.
## Useful for tilesets whose walls are different tiles from the ceiling.
## @tutorial(Walls Modifier): https://benjatk.github.io/Gaea/#/modifiers?id=-walls

## The tile to be placed. Will be placed below any tile
## that isn't the Generator's default tile.
@export var wall_tile: TileInfo


func apply(grid: GaeaGrid, generator: GaeaGenerator):
	# Check if the generator has a "settings" variable and if those
	# settings have a "tile" variable.
	if not generator.get("settings") or not generator.settings.get("tile"):
		push_warning("Walls modifier not compatible with %s" % generator.name)
		return grid

	var _temp_grid: GaeaGrid = grid.clone()
	for layer in affected_layers:
		for cell in grid.get_cells(layer):
			if not _passes_filter(grid, cell):
				continue

			if grid.get_value(cell, layer) == generator.settings.tile:
				var above: Vector2i = cell + Vector2i.UP
				if grid.has_cell(above, layer) and grid.get_value(above, layer) != generator.settings.tile:
					_temp_grid.set_value(cell, wall_tile)

	generator.grid = _temp_grid.clone()
	_temp_grid.unreference()
