@tool
@icon("fill.svg")
class_name Fill
extends Modifier2D
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


func apply(grid: GaeaGrid, _generator: GaeaGenerator) -> void:
	var rect: Rect2i
	for layer in affected_layers:
		for cell in grid.get_cells(layer):
			if not rect:
				rect = Rect2i(cell, Vector2i.ONE)
			rect = rect.expand(cell)

		rect = rect.grow_individual(expand_left, expand_top, expand_right, expand_bottom)

		for x in range(rect.position.x, rect.end.x + 1):
			for y in range(rect.position.y, rect.end.y + 1):
				var cell: Vector2i = Vector2i(x, y)
				if grid.has_cell(cell, layer):
					continue

				grid.set_value(cell, tile)
