@tool
@icon("fill.svg")
class_name Fill
extends Modifier
## Fills the full rectangle of tiles.
##@tutorial(Fill Modifier): https://benjatk.github.io/Gaea/#/modifiers?id=-fill


## A [TileInfo] containing information about the filling tile.
@export var tile: TileInfo
@export_group("Expand", "expand_")
## Expand the left side of the filled rectangle by this amount.
@export var expand_left := 1
## Expand the top side of the filled rectangle by this amount.
@export var expand_top := 1
## Expand the right side of the filled rectangle by this amount.
@export var expand_right := 1
## Expand the bottom side of the filled rectangle by this amount.
@export var expand_bottom := 1


func apply(grid: Dictionary, _generator: GaeaGenerator) -> Dictionary:
	var rect: Rect2
	for tile in grid:
		if not rect:
			rect = Rect2(tile, Vector2.ONE)
		rect = rect.expand(tile)

	rect = rect.grow_individual(
			expand_left, expand_top, expand_right, expand_bottom
			)

	for x in range(rect.position.x, rect.end.x + 1):
		for y in range(rect.position.y, rect.end.y + 1):
			var tile_pos: Vector2 = Vector2(x, y)
			if grid.has(tile_pos):
				continue

			grid[tile_pos] = tile
	return grid
