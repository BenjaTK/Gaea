@tool
@icon("generate_borders_modifier.svg")
class_name GenerateBorder extends Modifier
## Generates borders around the already placed tiles.


enum Mode {
	ADJACENT_ONLY, ## Only generates borders at the top, bottom, right and left of tiles.
	INCLUDE_DIAGONALS, ## Also generates diagonally to tiles.
}

@export var borderTileInfo: TileInfo
@export var mode: Mode = Mode.ADJACENT_ONLY
## If [code]true[/code], removes border tiles that don't have any neighbors of the same type.
@export var removeSingleWalls := false


var newGrid: Dictionary


func apply(grid: Dictionary, generator: GaeaGenerator) -> Dictionary:
	newGrid = grid.duplicate()

	_generate_border_walls(grid)

	if removeSingleWalls:
		_remove_single_walls(generator)

	return newGrid.duplicate()


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
				newGrid[tile + neighbor] = borderTileInfo


func _remove_single_walls(generator: GaeaGenerator) -> void:
	for tile in newGrid.keys():
		if not (newGrid[tile] == borderTileInfo):
			continue

		# If it doesn't have any neighbors of the same type,
		# set back to its original value
		if GaeaGenerator.get_neighbor_count_of_type(
				newGrid, tile, borderTileInfo) == 0:
			newGrid[tile] = generator.settings.tile



