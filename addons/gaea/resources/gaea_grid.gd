@tool
class_name GaeaGrid
extends Resource


var _grid: Dictionary


func add_layer(idx: int, grid: Dictionary, resource: GaeaLayer) -> void:
	if resource.enabled == false:
		_grid[idx] = {}
		return

	_grid[idx] = grid


func get_layer(idx: int) -> Dictionary:
	return _grid.get(idx)


func get_layers_count() -> int:
	return _grid.size()
