class_name GaeaGrid3D
extends GaeaGrid


## Returns the value at [param pos].
## If there's no value at that position, returns [code]null[/code].
func get_value(pos: Vector3i) -> Variant:
	return _grid.get(pos)


## Returns an [AABB] of the full extent of the grid.
func get_area() -> AABB:
	var cells = self.get_cells()
	if cells.is_empty():
		return AABB()

	var aabb: AABB = AABB(cells.front(), Vector3.ZERO)
	for cell in cells:
		aabb = aabb.expand(cell)
	return aabb
