@icon("wave_function_generator.svg")
@tool
class_name WaveFunctionGenerator2D
extends GaeaGenerator2D
## @experimental
## Generates a grid using a set of conditions for which tiles to place
## and which neighbors those tiles can have.
## @tutorial(An explanation of the algorithm and inspiration for this implementation by Martin Donald): https://www.youtube.com/watch?v=2SuvO4Gi7uY

const ADJACENT_NEIGHBORS: Dictionary = {
	"right": Vector2i.RIGHT, "left": Vector2i.LEFT, "up": Vector2i.UP, "down": Vector2i.DOWN
}

@export var settings: WaveFunctionGenerator2DSettings
## Limit max iterations to avoid infinite loops.
@export var max_iterations: int = 10000

var _wave_function: Dictionary


func generate(starting_grid: GaeaGrid = null) -> void:
	if Engine.is_editor_hint() and not editor_preview:
		push_warning("%s: Editor Preview is not enabled so nothing happened!" % name)
		return

	if not settings:
		push_error("%s doesn't have a settings resource" % name)
		return

	generation_started.emit()

	var _time_now: int = Time.get_ticks_msec()

	if starting_grid == null:
		erase()
	else:
		grid = starting_grid

	for x in settings.world_size.x:
		for y in settings.world_size.y:
			_wave_function[Vector2i(x, y)] = settings.entries.duplicate(true)

	var _iterations = 0
	while not _is_collapsed() and _iterations < max_iterations:
		_iterations += 1
		var coords := _get_lowest_entropy_coords()
		_collapse(coords)
		_propagate(coords)

	if _iterations == max_iterations:
		push_error("Generation reached max iterations.")

	for cell in _wave_function:
		grid.set_value(cell, _wave_function[cell][0].tile_info)

	_apply_modifiers(settings.modifiers)

	_wave_function.clear()

	if is_instance_valid(next_pass):
		next_pass.generate(grid)
		return

	var _time_elapsed: int = Time.get_ticks_msec() - _time_now
	if OS.is_debug_build():
		print("%s: Generating took %s seconds" % [name, float(_time_elapsed) / 1000])

	grid_updated.emit()
	generation_finished.emit()


func _collapse(coords: Vector2i) -> void:
	var entries: Array = _wave_function[coords].duplicate()
	if entries.is_empty():
		return

	var chosen: WaveFunction2DEntry
	var _total_weight: float = 0.0
	for entry in entries:
		_total_weight += entry.weight

	var _rand := randf_range(0.0, _total_weight)
	for entry in entries:
		_rand -= entry.weight
		if _rand < 0.0:
			chosen = entry
			break

	_wave_function[coords] = [chosen]


func _is_collapsed() -> bool:
	for tile in _wave_function:
		if _wave_function[tile].size() != 1:
			return false

	return true


func _propagate(coords: Vector2i) -> void:
	var stack = [coords]

	while stack.size() > 0:
		var current_coords = stack.pop_back()
		var entries: Array = _wave_function[coords]

		for dir in ADJACENT_NEIGHBORS.values():
			var other_coords: Vector2i = current_coords + dir
			if not _wave_function.has(other_coords):
				continue

			var other_possible_entries: Array = _wave_function[other_coords].duplicate()
			var possible_neighbors := _get_possible_neighbors(current_coords, dir)
			if possible_neighbors.size() == 0:
				continue

			for other_entry in other_possible_entries:
				if not other_entry in possible_neighbors:
					var _prev_len: int = _wave_function[other_coords].size()
					_wave_function[other_coords].erase(other_entry)
					if not other_coords in stack:
						stack.append(other_coords)


func _get_possible_neighbors(coords: Vector2i, direction: Vector2i) -> Array[WaveFunction2DEntry]:
	var possible_neighbors: Array[WaveFunction2DEntry]
	var dir_key = ADJACENT_NEIGHBORS.find_key(direction)
	for entry in _wave_function[coords]:
		for other_entry in _wave_function[coords + direction]:
			if other_entry.tile_info.id in entry.get("neighbors_%s" % dir_key):
				possible_neighbors.append(other_entry)

	return possible_neighbors


func _get_lowest_entropy_coords() -> Vector2i:
	var lowest_entropy: float = -1.0
	var lowest_entropy_coords: Vector2i = Vector2i.ZERO
	for coords in _wave_function:
		if _wave_function[coords].size() == 1:
			continue

		# With noise in case for randomization in case there's a tie.
		var entropy: float = _wave_function[coords].size() + (randf() / 1000)
		if entropy >= lowest_entropy and lowest_entropy != -1:
			continue

		lowest_entropy = entropy
		lowest_entropy_coords = coords

	return lowest_entropy_coords
