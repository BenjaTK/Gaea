@tool
@icon("generate_borders.svg")
class_name GenerateBorder
extends Modifier2D
## Generates borders around the already placed tiles.
##@tutorial(Generate Border Modifier): https://benjatk.github.io/Gaea/#/modifiers?id=-generate-borders

enum Mode {
	ADJACENT_ONLY,  ## Only generates borders at the top, bottom, right and left of tiles.
	INCLUDE_DIAGONALS,  ## Also generates diagonally to tiles.
}

@export var border_tile_info: TileInfo
@export var mode: Mode = Mode.ADJACENT_ONLY
## If [code]true[/code], removes border tiles that don't have any neighbors of the same type.
@export var remove_single_walls := false

var _temp_grid: GaeaGrid


func apply(grid: GaeaGrid, generator: GaeaGenerator) -> void:
	# Check if the generator has a "settings" variable and if those
	# settings have a "tile" variable.
	if not generator.get("settings") or not generator.settings.get("tile"):
		push_warning("GenerateBorder modifier not compatible with %s" % generator.name)
		return

	_temp_grid = grid.clone()

	_generate_border_walls(grid)

	generator.grid = _temp_grid.clone()
	_temp_grid.unreference()


func _generate_border_walls(grid: GaeaGrid) -> void:
	for layer in affected_layers:
		for cell in grid.get_cells(layer):
			var neighbors = GaeaGrid2D.SURROUNDING.duplicate()

			if mode != Mode.INCLUDE_DIAGONALS:
				for i in [Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, -1), Vector2i(-1, 1)]:
					neighbors.erase(i)

			# Get all empty neighbors and make it a border tile.
			for neighbor in neighbors:
				if not grid.has_cell(cell + neighbor, layer):
					_temp_grid.set_value(cell + neighbor, border_tile_info)
