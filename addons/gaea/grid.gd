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



