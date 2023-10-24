@tool
@icon("cellular_generator.svg")
class_name CellularGenerator
extends GaeaGenerator2D
## Generates a random noise grid, then uses cellular automata to smooth it out.
## Useful for islands-like terrain.
## @tutorial(Generators): https://benjatk.github.io/Gaea/#/generators/
## @tutorial(CellularGenerator): https://benjatk.github.io/Gaea/#/generators/cellular


@export var settings: CellularGeneratorSettings


func generate() -> void:
	if Engine.is_editor_hint() and not preview:
		return

	if not settings:
		push_error("%s doesn't have a settings resource" % name)
		return
	var time_now : float = Time.get_unix_time_from_system()
	erase()
	_set_noise()
	_smooth()
	_apply_modifiers(settings.modifiers)
	var time_elapsed : float = Time.get_unix_time_from_system() - time_now
	if OS.is_debug_build():
		print("Generating took %s seconds" % time_elapsed)
	grid_updated.emit()


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

	if not settings:
		warnings.append("Needs CellularGeneratorSettings to work.")

	return warnings
