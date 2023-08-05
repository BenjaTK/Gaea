@tool
@icon("fill.svg")
class_name Fill
extends Modifier
## Fills the full rectangle of tiles.


## A [TileInfo] containing information about the filling tile.
@export var tile: TileInfo
## Expands the rect's borders by this amount on both axis.
@export var expand_rect := 1


func apply(grid: Dictionary, _generator: GaeaGenerator) -> Dictionary:
	var rect
	for tile in grid:
		if not rect:
			rect = Rect2(tile, Vector2.ONE)
		rect = rect.expand(tile)

	rect = rect.grow(expand_rect)

	for x in range(rect.position.x, rect.end.x + 1):
		for y in range(rect.position.y, rect.end.y + 1):
			if grid.has(Vector2(x, y)):
				continue
			grid[Vector2(x, y)] = tile
	return grid
