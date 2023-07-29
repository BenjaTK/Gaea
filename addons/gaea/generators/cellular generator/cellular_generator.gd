@tool
@icon("cellular_generator.svg")
class_name CellularGenerator extends GaeaGenerator
## Generates a random noise grid, then uses cellular automata to smooth it out.
## Useful for islands-like terrain.


## If [code]true[/code], allows for generating a preview of the generation
## in the editor. Useful for debugging.
@export var preview: bool = false :
	set(value):
		preview = value
		if value == false:
			erase()

@export var settings: CellularGeneratorSettings


func generate() -> void:
	if Engine.is_editor_hint() and not preview:
		return

	if not settings or not is_instance_valid(tileMap):
		return

	erase()
	_set_noise()
	_smooth()
	_apply_modifiers()
	_draw_tiles()


func _set_noise() -> void:
	for x in range(settings.worldSize.x):
		for y in range(settings.worldSize.y):
			if randf() > settings.noiseDensity:
				grid[Vector2(x, y)] = Tiles.FLOOR
			else:
				grid[Vector2(x, y)] = Tiles.EMPTY


func _smooth() -> void:
	for i in settings.smoothIterations:
		var tempGrid: Dictionary = grid.duplicate()
		for tile in grid.keys():
			var deadNeighborsCount := GaeaGenerator.get_neighbor_count_of_type(
				grid, tile, GaeaGenerator.Tiles.EMPTY
			)
			if grid[tile] == Tiles.FLOOR and deadNeighborsCount > settings.maxFloorEmptyNeighbors:
				tempGrid[tile] = Tiles.EMPTY
			elif grid[tile] == Tiles.EMPTY and deadNeighborsCount <= settings.minEmptyNeighbors:
				tempGrid[tile] = Tiles.FLOOR
		grid = tempGrid

	for tile in grid.keys():
		if grid[tile] == GaeaGenerator.Tiles.EMPTY:
			grid.erase(tile)


func _apply_modifiers() -> void:
	for modifier in settings.modifiers:
		if not (modifier is Modifier):
			continue

		grid = modifier.apply(grid)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray

	warnings.append_array(super._get_configuration_warnings())

	if not settings:
		warnings.append("Needs CellularGeneratorSettings to work.")

	return warnings
