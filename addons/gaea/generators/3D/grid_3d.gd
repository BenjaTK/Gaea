class_name GaeaGrid3D
extends GaeaGrid
## @tutorial(Gaea's Resources): https://benjatk.github.io/Gaea/#/resources

const NEIGHBORS := [
	Vector3i.RIGHT, Vector3i.LEFT,
	Vector3i.UP, Vector3i.DOWN,
	Vector3i.FORWARD, Vector3i.BACK
]


## Sets the value at the given position to [param value].
func set_value(pos: Vector3i, value: Variant, layer: int = -1) -> void:
	super(pos, value, layer)


## Sets the value at the given position to [param value].
func set_valuexyz(x: int, y: int, z: int, value: Variant, layer: int = -1) -> void:
	set_value(Vector3i(x, y, z), value, layer)


## Returns the value at the given position.
## If there's no value at that position, returns [code]null[/code].
func get_value(pos: Vector3i, layer: int) -> Variant:
	return super(pos, layer)


## Returns the value at the given position.
## If there's no value at that position, returns [code]null[/code].
func get_valuexyz(x: int, y: int, z: int, layer: int) -> Variant:
	return get_value(Vector3i(x, y, z), layer)


## Returns an [AABB] of the full extent of the grid.
func get_area() -> AABB:
	var aabb: AABB
	for layer in range(get_layer_count()):
		var cells = get_cells(layer)
		if cells.is_empty():
			continue

		if aabb == AABB():
			aabb = AABB(cells.front(), Vector3i.ZERO)

		for cell in cells:
			aabb = aabb.expand(cell)
	return aabb


## Returns [code]true[/code] if the grid has a cell at the given position.
func has_cell(pos: Vector3i, layer: int) -> bool:
	return super(pos, layer)


## Returns [code]true[/code] if the grid has a cell at the given position.
func has_cellxyz(x: int, y: int, z: int, layer: int) -> bool:
	return has_cell(Vector3i(x, y, z), layer)


## Removes the cell at the given position from the grid.
func erase(pos: Vector3i, layer: int) -> void:
	super(pos, layer)


## Removes the cell at the given position from the grid.
func erasexyz(x: int, y: int, z: int, layer: int) -> void:
	erase(Vector3i(x, y, z), layer)


## Returns [code]true[/code] if the cell at the given position has a non-existing neighbor. Doesn't include diagonals.
func has_empty_neighbor(pos: Vector3i, layer: int) -> bool:
	for neighbor in NEIGHBORS:
		if not has_cell(pos + neighbor, layer) or get_value(pos + neighbor, layer) == null:
			return true

	return false
