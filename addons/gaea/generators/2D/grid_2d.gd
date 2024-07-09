class_name GaeaGrid2D
extends GaeaGrid
## @tutorial(Gaea's Resources): https://benjatk.github.io/Gaea/#/resources

const SURROUNDING := [
	Vector2i.RIGHT, Vector2i.LEFT,
	Vector2i.UP, Vector2i.DOWN,
	Vector2i(1, 1), Vector2i(1, -1),
	Vector2i(-1, -1), Vector2i(-1, 1)
]



## Sets the value at the given position to [param value].
func set_value(pos: Vector2i, value: Variant, layer: int = -1) -> void:
	super(pos, value, layer)


## Sets the value at the given position to [param value].
func set_valuexy(x: int, y: int, value: Variant, layer: int = -1) -> void:
	set_value(Vector2i(x, y), value, layer)


## Returns the value at the given position.
## If there's no value at that position, returns [code]null[/code].
func get_value(pos: Vector2i, layer: int) -> Variant:
	return super(pos, layer)


## Returns the value at the given position.
## If there's no value at that position, returns [code]null[/code].
func get_valuexy(x: int, y: int, layer: int) -> Variant:
	return get_value(Vector2i(x, y), layer)


## Returns a [Rect2i] of the full extent of the grid.
func get_area() -> Rect2i:
	var rect: Rect2i
	for layer in range(get_layer_count()):
		var cells = get_cells(layer)
		if cells.is_empty():
			continue

		if rect == Rect2i():
			rect = Rect2i(cells.front(), Vector2i.ZERO)

		for cell in cells:
			rect = rect.expand(cell)
	return rect


## Returns [code]true[/code] if the grid has a cell at the given position.
func has_cell(pos: Vector2i, layer: int) -> bool:
	if not has_layer(layer):
		return false
	return super(pos, layer)


## Returns [code]true[/code] if the grid has a cell at the given position.
func has_cellxy(x: int, y: int, layer: int) -> bool:
	return has_cell(Vector2i(x, y), layer)


## Removes the cell at the given position from the grid.
func erase(pos: Vector2i, layer: int) -> void:
	super(pos, layer)


## Removes the cell at the given position from the grid.
func erasexy(x: int, y: int, layer: int) -> void:
	erase(Vector2i(x, y), layer)


## Returns the amount of non-existing and null cells (including corners) around the given position.
func get_amount_of_empty_neighbors(pos: Vector2i, layer: int) -> int:
	var count: int = 0

	for n in SURROUNDING:
		if get_value(pos + n, layer) == null:
			count += 1

	return count


## Returns an array with the positions of all cells surrounding the given position, including corners.[br]
## If [param ignore_empty] is [code]true[/code], all non-existing cells will not be counted. Cells of value [code]null[/code] will still be counted.
func get_surrounding_cells(pos: Vector2i, layer: int, ignore_empty: bool = false) -> Array[Vector2i]:
	var surrounding: Array[Vector2i]

	for n in SURROUNDING:
		if ignore_empty and not has_cell(pos + n, layer):
			continue
		surrounding.append(pos + n)

	return surrounding
