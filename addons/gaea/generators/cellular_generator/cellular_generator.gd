@tool
@icon("cellular_generator.svg")
class_name CellularGenerator
extends GaeaGenerator
## Generates a random noise grid, then uses cellular automata to smooth it out.
## Useful for islands-like terrain.


@export var settings: CellularGeneratorSettings


func generate() -> void:
	if Engine.is_editor_hint() and not preview:
		return

	super.generate()

	if not settings:
		push_error("%s doesn't have a settings resource" % name)
		return

	erase(clear_tilemap_on_generation)
	_set_noise()
	_smooth()
	_apply_modifiers(settings.modifiers)
	_draw_tiles()


func _set_noise() -> void:
	for x in range(settings.world_size.x):
		for y in range(settings.world_size.y):
			if randf() > settings.noise_density:
				grid[Vector2(x, y)] = settings.tile
			else:
				grid[Vector2(x, y)] = null


func _smooth() -> void:
	for i in settings.smooth_iterations:
		var tempGrid: Dictionary = grid.duplicate()
		for tile in grid.keys():
			var deadNeighborsCount := get_neighbor_count_of_type(
				grid, tile, null
			)
			if grid[tile] == settings.tile and deadNeighborsCount > settings.max_floor_empty_neighbors:
				tempGrid[tile] = null
			elif grid[tile] == null and deadNeighborsCount <= settings.min_empty_neighbors:
				tempGrid[tile] = settings.tile
		grid = tempGrid

	for tile in grid.keys():
		if grid[tile] == null:
			grid.erase(tile)


### Editor ###


func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray

	warnings.append_array(super._get_configuration_warnings())

	if not settings:
		warnings.append("Needs CellularGeneratorSettings to work.")

	return warnings
