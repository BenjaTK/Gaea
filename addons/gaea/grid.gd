class_name GaeaGrid
extends Resource
## The grid which all [GaeaGenerator]s fill, and the base
## of the Gaea plugin.


var _grid: Dictionary


## Returns the value at [param pos].
## If there's no value at that position, returns [code]null[/code].
func get_value(pos: Vector2i) -> Variant:
	return _grid.get(pos)


## Sets the value at [param pos] to [param value].
func set_value(pos: Vector2i, value: Variant) -> void:
	_grid[pos] = value


func get_cells() -> Array[Vector2]:
	return _grid.keys() as Array[Vector2]


## Clears the grid, removing all cells.
func clear() -> void:
	_grid.clear()


### Helper Functions ###


## Returns a [Rect2i] with the full extent of the grid.
static func get_rect_from_grid(grid: GaeaGrid) -> Rect2i:
	var cells = grid.get_cells()
	if cells.is_empty():
		return Rect2i()

	var rect: Rect2i = Rect2i(cells.front(), Vector2.ZERO)
	for cell in cells:
		rect = rect.expand(cell)
	return rect


## Returns an [AABB] with the full extent of the grid.
static func get_aabb_from_grid(grid: GaeaGrid) -> AABB:
	var cells = grid.get_cells()
	if cells.is_empty():
		return AABB()

	var aabb: AABB = AABB(cells.front(), Vector3.ZERO)
	for cell in cells:
		aabb = aabb.expand(cell)
	return aabb
