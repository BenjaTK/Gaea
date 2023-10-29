class_name GaeaGrid
extends Resource
## The grid which all [GaeaGenerator]s fill, and the base
## of the Gaea plugin.


var _grid: Dictionary


### Values ###


## Sets the value at the given position to [param value].
func set_value(pos, value: Variant) -> void:
	if value is RandomTileInfo:
		set_value(pos, value.get_random())
		return

	_grid[pos] = value


## Returns the value at the given position.
## If there's no value at that position, returns [code]null[/code].
func get_value(pos) -> Variant:
	return _grid.get(pos)


## Returns an [Array] of all values in the grid.
func get_values() -> Array[Variant]:
	return _grid.values()


## Sets the grid [Dictionary] to [param grid].
func set_grid(grid: Dictionary) -> void:
	_grid = grid


## Returns the grid [Dictionary].
func get_grid() -> Dictionary:
	return _grid


### Cells ###


## Returns an [Array] of all cells in the grid.
func get_cells() -> Array:
	return _grid.keys()


## Returns [code]true[/code] if the grid has a cell at the given position.
func has_cell(pos) -> bool:
	return _grid.has(pos)


### Erasing ###

## Removes the cell at the given position from the grid.
func erase(pos) -> void:
	_grid.erase(pos)


## Clears the grid, removing all cells.
func clear() -> void:
	_grid.clear()


## Erases all cells of value [code]null[/code].
func erase_invalid() -> void:
	for cell in get_cells():
		if get_value(cell) == null:
			erase(cell)


### Utilities ###

## Use this instead of `duplicate()` as it is broken on custom resources.
func clone() -> GaeaGrid:
	var instance = get_script().new()

	instance.set_grid(_grid.duplicate(true))

	return instance
