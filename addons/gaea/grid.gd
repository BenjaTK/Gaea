class_name GaeaGrid
extends Resource
## The grid which all [GaeaGenerator]s fill, and the base
## of the Gaea plugin.
## @tutorial(Gaea's Resources): https://benjatk.github.io/Gaea/#/resources

## Holds the layers as subdictionaries containing values for each position.
var _grid: Dictionary

### Values ###


## Sets the value at the given position to [param value].
## [br]
## If [param layer] is negative, it is ignored,
## and if [param value] is a [TileInfo], it takes its [param layer].
## Otherwise, layer is set to [code]0[/code].
func set_value(pos, value: Variant, layer: int = -1) -> void:
	if value is RandomTileInfo:
		set_value(pos, value.get_random(), layer)
		return

	if layer < 0:
		if value is TileInfo:
			layer = value.layer
		else:
			layer = 0

	if not has_layer(layer):
		add_layer(layer)

	_grid[layer][pos] = value


## Returns the value at the given position.
## If there's no value at that position, returns [code]null[/code].
func get_value(pos, layer: int) -> Variant:
	if not has_layer(layer):
		return null
	return _grid[layer].get(pos)


## Returns an [Array] of all values in the grid.
func get_values(layer: int) -> Array[Variant]:
	if not has_layer(layer):
		push_error("Index layer = %s is out of bounds (get_layer_count() = %s)" % [layer, get_layer_count()])
		return []
	return _grid[layer].values()


## Sets the grid [Array] to [param grid].
func set_grid(grid: Dictionary) -> void:
	_grid = grid


## Sets the grid to the serialized grid that [param bytes] represents. See [method GaeaGenerator.serialize] and [method GaeaGenerator.deserialize].
func set_grid_serialized(bytes: PackedByteArray) -> void:
	var grid = bytes_to_var(bytes)
	if not (grid is Dictionary):
		push_error("Attempted to deserialize invalid grid")
		return

	for layer in grid:
		for tile in grid[layer]:
			var object = grid[layer][tile]
			if object is EncodedObjectAsID:
				grid[layer][tile] = instance_from_id(object.get_object_id())
	_grid = grid


## Returns the grid [Dictionary].
func get_grid() -> Dictionary:
	return _grid


### Cells ###


## Returns an [Array] of all cells in the grid.
func get_cells(layer: int) -> Array:
	if not has_layer(layer):
		push_error("Index layer = %s is out of bounds (get_layer_count() = %s)" % [layer, get_layer_count()])
		return []
	return _grid[layer].keys()


## Returns [code]true[/code] if the grid has a cell at the given position.
func has_cell(pos, layer: int) -> bool:
	if not has_layer(layer):
		return false
	return _grid[layer].has(pos)


### Erasing ###


## Removes the cell at the given position from the grid.
func erase(pos, layer: int) -> void:
	if has_cell(pos, layer):
		_grid[layer].erase(pos)


## Clears the grid, removing all cells.
func clear() -> void:
	_grid.clear()


## Erases all cells of value [code]null[/code].
func erase_invalid() -> void:
	for layer: int in range(get_layer_count()):
		for cell in get_cells(layer):
			if get_value(cell, layer) == null:
				erase(cell, layer)


### Utilities ###

### Layers ###


func has_layer(idx: int) -> bool:
	return _grid.has(idx)


func get_layer_count() -> int:
	return _grid.size()


func add_layer(idx: int) -> void:
	if _grid.has(idx):
		return

	_grid[idx] = {}


func get_area() -> Variant:
	return null


## Use this instead of `duplicate()` as it is broken on custom resources.
func clone() -> GaeaGrid:
	var instance = get_script().new()

	instance.set_grid(_grid.duplicate(true))

	return instance
