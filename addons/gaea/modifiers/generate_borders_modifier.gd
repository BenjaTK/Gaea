@tool
@icon("generate_borders_modifier.svg")
class_name GenerateBorder extends Modifier
## Generates borders around the already placed tiles.


enum Mode {
	ADJACENT_ONLY, ## Only generates borders at the top, bottom, right and left of tiles.
	INCLUDE_DIAGONALS, ## Also generates diagonally to tiles.
	FULL_RECT ## Generates a rectangle filling the extents of the tiles.
}

@export var borderTileInfo: TileInfo
@export var mode: Mode = Mode.ADJACENT_ONLY
## If [code]true[/code], removes border tiles that don't have any neighbors of the same type.
@export var removeSingleWalls := false
## If [param mode] is set to [code]Rect[/code], it expands the rect's borders by
## this amount on both axis.
@export var expandRect := 1

var newGrid: Dictionary


func apply(grid: Dictionary, generator: GaeaGenerator) -> Dictionary:
	newGrid = grid.duplicate()

	match mode:
		Mode.ADJACENT_ONLY, Mode.INCLUDE_DIAGONALS:
			_generate_border_walls(grid)
		Mode.FULL_RECT:
			_generate_rect()

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
			newGrid[tile] = generator.defaultTileInfo


func _generate_rect() -> void:
	var rect
	for tile in newGrid:
		if not rect:
			rect = Rect2(tile, Vector2.ONE)
		rect = rect.expand(tile)

	rect = rect.grow(expandRect)

	for x in range(rect.position.x, rect.end.x + 1):
		for y in range(rect.position.y, rect.end.y + 1):
			if newGrid.has(Vector2(x, y)):
				continue
			newGrid[Vector2(x, y)] = borderTileInfo
