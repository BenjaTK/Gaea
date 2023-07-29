@tool
@icon("cellular_generator.svg")
class_name CellularGenerator extends GaeaGenerator


## If [code]true[/code], allows for generating a preview of the generation
## in the editor. Useful for checking parameters.
@export var preview: bool = false :
	set(value):
		preview = value
		if value == false:
			remove()

@export var parameters: CellularGeneratorParameters


func generate() -> void:
	if Engine.is_editor_hint() and not preview:
		return

	if not parameters or not is_instance_valid(tileMap):
		return

	remove()
	_set_noise()
	_smooth()
	_apply_modifiers()
	_place_tiles()


func _set_noise() -> void:
	for x in range(parameters.worldSize.x):
		for y in range(parameters.worldSize.y):
			if randf() > parameters.noiseDensity:
				grid[Vector2(x, y)] = Tiles.FLOOR
			else:
				grid[Vector2(x, y)] = Tiles.EMPTY


func _smooth() -> void:
	for i in parameters.smoothIterations:
		var tempGrid: Dictionary = grid.duplicate()
		for tile in grid.keys():
			var deadNeighborsCount := GaeaGenerator.get_neighbor_count_of_type(
				grid, tile, GaeaGenerator.Tiles.EMPTY
			)
			if grid[tile] == Tiles.FLOOR and deadNeighborsCount > parameters.maxFloorEmptyNeighbors:
				tempGrid[tile] = Tiles.EMPTY
			elif grid[tile] == Tiles.EMPTY and deadNeighborsCount <= parameters.minEmptyNeighbors:
				tempGrid[tile] = Tiles.FLOOR
		grid = tempGrid

	for tile in grid.keys():
		if grid[tile] == GaeaGenerator.Tiles.EMPTY:
			grid.erase(tile)


func _apply_modifiers() -> void:
	for modifier in parameters.modifiers:
		if not (modifier is Modifier):
			continue

		grid = modifier.apply(grid)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray

	warnings.append_array(super._get_configuration_warnings())

	if not parameters:
		warnings.append("Needs CellularGeneratorParameters to work.")

	return warnings
