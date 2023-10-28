class_name GaeaGrid3D
extends GaeaGrid


const NEIGHBORS := [Vector3i.RIGHT, Vector3i.LEFT, Vector3i.UP, Vector3i.DOWN,
					Vector3i.FORWARD, Vector3i.BACK]



## Sets the value at [param pos] to [param value].
func set_value(pos: Vector3i, value: Variant) -> void:
	_grid[pos] = value


## Returns the value at [param pos].
## If there's no value at that position, returns [code]null[/code].
func get_value(pos: Vector3i) -> Variant:
	return _grid.get(pos)


## Returns an [AABB] of the full extent of the grid.
func get_area() -> AABB:
	var cells = self.get_cells()
	if cells.is_empty():
		return AABB()

	var aabb: AABB = AABB(cells.front(), Vector3i.ZERO)
	for cell in cells:
		aabb = aabb.expand(cell)
	return aabb


## Returns [code]true[/code] if the grid has a cell at [param pos].
func has_cell(pos: Vector3i) -> bool:
	return _grid.has(pos)


## Removes the cell at [param pos] from the grid.
func erase(pos: Vector3i) -> void:
	_grid.erase(pos)


## Returns [code]true[/code] if the cell at [param pos] has a non-existing neighbor. Doesn't include diagonals.
func has_empty_neighbor(pos: Vector3i) -> bool:
	for neighbor in NEIGHBORS:
		if not has_cell(pos + neighbor):
			return true

	return false
