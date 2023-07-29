@tool
class_name GenerateWalls
extends Modifier
## Generates walls.


enum Mode {
	ADJACENT_ONLY, ## Only generates walls at the top, bottom, right and left of floors.
	INCLUDE_DIAGONALS, ## Also generates diagonally to floors.
	FULL_RECT ## Generates a rectangle filling the extents of the floor tiles.
}

@export var mode: Mode = Mode.ADJACENT_ONLY
## If [code]true[/code], removes walls completely surrounded by floors.
@export var removeSingleWalls := false
## If [param mode] is set to [code]Rect[/code], it expands the rect's borders by
## this amount on both axis.
@export var expandRect := 1


func apply(grid: Dictionary) -> Dictionary:
	match mode:
		Mode.ADJACENT_ONLY, Mode.INCLUDE_DIAGONALS:
			_generate_border_walls(grid)
		Mode.FULL_RECT:
			_generate_rect(grid)

	if removeSingleWalls:
		_remove_single_walls(grid)

	return grid

func _generate_border_walls(grid: Dictionary) -> void:
	for tile in grid:
		if not (grid[tile] == GaeaGenerator.Tiles.FLOOR):
			continue

		var neighbors = [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]

		if mode == Mode.INCLUDE_DIAGONALS:
			neighbors.append_array(
				[Vector2(1, 1), Vector2(1, -1), Vector2(-1, -1), Vector2(-1, 1)]
				)

		for neighbor in neighbors:
			if not grid.has(tile + neighbor):
				grid[tile + neighbor] = GaeaGenerator.Tiles.WALL



func _remove_single_walls(grid: Dictionary) -> void:
	for tile in grid.keys():
		if not (grid[tile] == GaeaGenerator.Tiles.WALL):
			continue

		if GaeaGenerator.are_all_neighbors_of_type(grid, tile, GaeaGenerator.Tiles.FLOOR):
			grid[tile] = GaeaGenerator.Tiles.FLOOR


func _generate_rect(grid: Dictionary) -> void:
	var rect = Rect2()
	for tile in grid:
		rect = rect.expand(tile)

	rect = rect.grow(expandRect)

	for x in range(rect.position.x, rect.end.x + 1):
		for y in range(rect.position.y, rect.end.y + 1):
			if grid.has(Vector2(x, y)):
				continue
			grid[Vector2(x, y)] = GaeaGenerator.Tiles.WALL
