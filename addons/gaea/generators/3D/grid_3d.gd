class_name GaeaGrid3D
extends GaeaGrid


const NEIGHBORS := [Vector3i.RIGHT, Vector3i.LEFT, Vector3i.UP, Vector3i.DOWN,
					Vector3i.FORWARD, Vector3i.BACK]



## Sets the value at the given position to [param value].
func set_value(pos: Vector3i, value: Variant) -> void:
	super(pos, value)


## Sets the value at the given position to [param value].
func set_valuexyz(x: int, y: int, z: int, value: Variant) -> void:
	set_value(Vector3i(x, y, z), value)


## Returns the value at the given position.
## If there's no value at that position, returns [code]null[/code].
func get_value(pos: Vector3i) -> Variant:
	return super(pos)


## Returns the value at the given position.
## If there's no value at that position, returns [code]null[/code].
func get_valuexyz(x: int, y: int, z: int) -> Variant:
	return get_value(Vector3i(x, y, z))


## Returns an [AABB] of the full extent of the grid.
func get_area() -> AABB:
	var cells = self.get_cells()
	if cells.is_empty():
		return AABB()

	var aabb: AABB = AABB(cells.front(), Vector3i.ZERO)
	for cell in cells:
		aabb = aabb.expand(cell)
	return aabb


## Returns [code]true[/code] if the grid has a cell at the given position.
func has_cell(pos: Vector3i) -> bool:
	return super(pos)


## Returns [code]true[/code] if the grid has a cell at the given position.
func has_cellxyz(x: int, y: int, z: int) -> bool:
	return has_cell(Vector3i(x, y, z))


## Removes the cell at the given position from the grid.
func erase(pos: Vector3i) -> void:
	super(pos)


## Removes the cell at the given position from the grid.
func erasexyz(x: int, y: int, z: int) -> void:
	erase(Vector3i(x, y, z))


## Returns [code]true[/code] if the cell at the given position has a non-existing neighbor. Doesn't include diagonals.
func has_empty_neighbor(pos: Vector3i) -> bool:
	for neighbor in NEIGHBORS:
		if not has_cell(pos + neighbor):
			return true

	return false
