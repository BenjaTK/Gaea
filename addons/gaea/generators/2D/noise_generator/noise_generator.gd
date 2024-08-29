@tool
@icon("noise_generator.svg")
class_name NoiseGenerator
extends ChunkAwareGenerator2D
## Takes a Dictionary of thresholds and tiles to generate organic terrain with different tiles for different heights.
## @tutorial(Generators): https://benjatk.github.io/Gaea/#/generators/
## @tutorial(NoiseGenerator): https://benjatk.github.io/Gaea/#/generators/noise

@export var settings: NoiseGeneratorSettings


func generate(starting_grid: GaeaGrid = null) -> void:
	if Engine.is_editor_hint() and not editor_preview:
		push_warning("%s: Editor Preview is not enabled so nothing happened!" % name)
		return

	if not settings:
		push_error("%s doesn't have a settings resource" % name)
		return

	generation_started.emit()

	var _time_now: int = Time.get_ticks_msec()

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
		return

	if not settings:
		push_error("%s doesn't have a settings resource" % name)
		return

	if starting_grid == null:
		erase_chunk(chunk_position)
	else:
		grid = starting_grid

	_set_grid_chunk(chunk_position)
	_apply_modifiers_chunk(settings.modifiers, chunk_position)

	generated_chunks.append(chunk_position)

	if is_instance_valid(next_pass):
		if not next_pass is ChunkAwareGenerator2D:
			push_error("next_pass generator is not a ChunkAwareGenerator2D")
		else:
			next_pass.generate_chunk(chunk_position, grid)
			return

	(func(): chunk_updated.emit(chunk_position)).call_deferred()  # Deferred for thread-safety.
	(func(): chunk_generation_finished.emit(chunk_position)).call_deferred()  # Deferred for thread-safety.


func _set_grid() -> void:
	_set_grid_area(Rect2i(Vector2i.ZERO, Vector2i(settings.world_size)))


func _set_grid_chunk(chunk_position: Vector2i) -> void:
	_set_grid_area(Rect2i(chunk_position * chunk_size, chunk_size))


func _set_grid_area(rect: Rect2i) -> void:
	for x in range(rect.position.x, rect.end.x):
		if not settings.infinite:
			if x < 0 or x > settings.world_size.x:
				continue

		for y in range(rect.position.y, rect.end.y):
			if not settings.infinite:
				if y < 0 or y > settings.world_size.x:
					continue

			var noise = settings.noise.get_noise_2d(x, y)
			if settings.falloff_enabled and settings.falloff_map and not settings.infinite:
				noise = ((noise + 1) * settings.falloff_map.get_value(Vector2i(x, y))) - 1.0

			for tile_data in settings.tiles:
				## Check if the noise is within the threshold
				if noise >= tile_data.min and noise <= tile_data.max:
					grid.set_valuexy(x, y, tile_data.tile)
