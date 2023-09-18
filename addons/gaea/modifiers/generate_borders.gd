@tool
@icon("generate_borders.svg")
class_name GenerateBorder
extends Modifier2D
## Generates borders around the already placed tiles.
##@tutorial(Generate Border Modifier): https://benjatk.github.io/Gaea/#/modifiers?id=-generate-borders


enum Mode {
	ADJACENT_ONLY, ## Only generates borders at the top, bottom, right and left of tiles.
	INCLUDE_DIAGONALS, ## Also generates diagonally to tiles.
}

@export var border_tile_info: TileInfo
@export var mode: Mode = Mode.ADJACENT_ONLY
## If [code]true[/code], removes border tiles that don't have any neighbors of the same type.
@export var remove_single_walls := false

var _new_grid: Dictionary


func apply(grid: Dictionary, generator: GaeaGenerator) -> Dictionary:
	# Check if the generator has a "settings" variable and if those
	# settings have a "tile" variable.
	if not generator.get("settings") or not generator.settings.get("tile"):
		push_warning("GenerateBorder modifier not compatible with %s" % generator.name)
		return grid

	_new_grid = grid.duplicate()

	_generate_border_walls(grid)

	if remove_single_walls:
		_remove_single_walls(generator)

	return _new_grid.duplicate()


func _generate_border_walls(grid: Dictionary) -> void:
	for tile in grid:
		var neighbors = [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]

		if mode == Mode.INCLUDE_DIAGONALS:
			neighbors.append_array(
				[Vector2(1, 1), Vector2(1, -1), Vector2(-1, -1), Vector2(-1, 1)]
				)

		# Get all empty neighbors and make it a border tile.
		for neighbor in neighbors:
			if not grid.has(tile + neighbor):
				_new_grid[tile + neighbor] = border_tile_info


func _remove_single_walls(generator: GaeaGenerator) -> void:
	for tile in _new_grid.keys():
		if not (_new_grid[tile] == border_tile_info):
			continue

		# If it doesn't have any neighbors of the same type,
		# set back to its original value
		if GaeaGenerator.get_neighbor_count_of_type(
				_new_grid, tile, border_tile_info) == 0:
			_new_grid[tile] = generator.settings.tile



