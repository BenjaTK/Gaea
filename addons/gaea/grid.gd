class_name GaeaGrid
extends Resource
## The grid which all [GaeaGenerator]s fill, and the base
## of the Gaea plugin.


var _grid: Dictionary


## Sets the value at [param pos] to [param value].
func set_value(pos, value: Variant) -> void:
	_grid[pos] = value


## Returns the value at [param pos].
## If there's no value at that position, returns [code]null[/code].
func get_value(pos) -> Variant:
	return _grid.get(pos)


### Getters ###


## Returns an [Array] of all cells in the grid.
func get_cells() -> Array:
	return _grid.keys()


## Returns an [Array] of all values in the grid.
func get_values() -> Array[Variant]:
	return _grid.values()


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


## Use this instead of `duplicate()` as it is broken on custom resources.
func clone() -> GaeaGrid:
	var instance = get_script().new()

	instance._grid = _grid.duplicate()

	return instance
