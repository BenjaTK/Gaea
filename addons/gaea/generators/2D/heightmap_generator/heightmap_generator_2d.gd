@tool
@icon("heightmap_generator_2d.svg")
class_name HeightmapGenerator2D
extends ChunkAwareGenerator2D
## Generates terrain using a heightmap from a noise texture.
## @tutorial(Generators): https://benjatk.github.io/Gaea/#/generators/
## @tutorial(HeightmapGenerator): https://benjatk.github.io/Gaea/#/generators/heightmap

@export var settings: HeightmapGenerator2DSettings


func generate(starting_grid: GaeaGrid = null) -> void:
	if Engine.is_editor_hint() and not editor_preview:
		push_warning("%s: Editor Preview is not enabled so nothing happened!" % name)
		return

	if not settings:
		push_error("%s doesn't have a settings resource" % name)
		return

	var _time_now: int = Time.get_ticks_msec()

	generation_started.emit()

	settings.noise.seed = seed

	if starting_grid == null:
		erase()
	else:
		grid = starting_grid
	_set_grid()
	_apply_modifiers(settings.modifiers)

	if is_instance_valid(next_pass):
		next_pass.generate(grid)
		return

	var _time_elapsed: int = Time.get_ticks_msec() - _time_now
	if OS.is_debug_build():
		print("%s: Generating took %s seconds" % [name, float(_time_elapsed) / 1000])

	grid_updated.emit()
	generation_finished.emit()


func generate_chunk(chunk_position: Vector2i, starting_grid: GaeaGrid = null) -> void:
	if Engine.is_editor_hint() and not editor_preview:
		push_warning("%s: Editor Preview is not enabled so nothing happened!" % name)
		return

	if not settings:
		push_error("%s doesn't have a settings resource" % name)
		return

	if starting_grid == null:
		erase_chunk(chunk_position)
	else:
		grid = starting_grid

	_set_chunk_grid(chunk_position)
	_apply_modifiers_chunk(settings.modifiers, chunk_position)

	generated_chunks.append(chunk_position)

	if is_instance_valid(next_pass):
		if not next_pass is ChunkAwareGenerator2D:
			push_error("next_pass generator is not a ChunkAwareGenerator2D")
		else:
			next_pass.generate_chunk(chunk_position, grid)
			return

	(func(): chunk_updated.emit(chunk_position)).call_deferred()  # deferred for threadability
	(func(): chunk_generation_finished.emit(chunk_position)).call_deferred()  # deferred for threadability


func _set_grid() -> void:
	var max_height: int = 0
	for x in range(settings.world_length):
		max_height = maxi(
			floor(settings.noise.get_noise_1d(x) * settings.height_intensity + settings.height_offset), max_height
		) + 1

	var area := Rect2i(
		# starting point
		Vector2i(0, -max_height),
		# size
		Vector2i(settings.world_length, max_height - settings.min_height)
	)

	_set_grid_area(area)


func _set_chunk_grid(chunk_position: Vector2i) -> void:
	_set_grid_area(Rect2i(chunk_position * chunk_size, chunk_size))


func _set_grid_area(area: Rect2i) -> void:
	for x in range(area.position.x, area.end.x):
		if not settings.infinite:
			if x < 0 or x > settings.world_length:
				continue

		var height = floor(settings.noise.get_noise_1d(x) * settings.height_intensity + settings.height_offset)
		for y in range(area.position.y, area.end.y):
			if y >= -height and y <= -settings.min_height:
				grid.set_valuexy(x, y, settings.tile)
			elif y == -height - 1 and settings.air_layer:
				grid.set_valuexy(x, y, null)
