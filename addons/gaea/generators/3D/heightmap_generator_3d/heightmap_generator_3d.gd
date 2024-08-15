@tool
class_name HeightmapGenerator3D
extends ChunkAwareGenerator3D
## Generates terrain using a heightmap from a noise texture.
## @tutorial(Generators): https://benjatk.github.io/Gaea/#/generators/
## @tutorial(HeightmapGenerator): https://benjatk.github.io/Gaea/#/generators/heightmap

@export var settings: HeightmapGenerator3DSettings


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

	var _time_elapsed: int = Time.get_ticks_msec() - _time_now
	if OS.is_debug_build():
		print("%s: Generating took %s seconds" % [name, float(_time_elapsed) / 1000])

	grid_updated.emit()
	generation_finished.emit()


func generate_chunk(chunk_position: Vector3i, starting_grid: GaeaGrid = null) -> void:
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
		if not next_pass is ChunkAwareGenerator3D:
			push_error("next_pass generator is not a ChunkAwareGenerator3D")
		else:
			next_pass.generate_chunk(chunk_position, grid)
			return

	(func(): chunk_updated.emit(chunk_position)).call_deferred()  # deferred for threadability
	(func(): chunk_generation_finished.emit(chunk_position)).call_deferred()  # deferred for threadability


func _set_grid() -> void:
	var max_height: int = 0
	for x in range(settings.world_size.x):
		for z in range(settings.world_size.y):
			max_height = maxi(
				floor(settings.noise.get_noise_2d(x, z) * settings.height_intensity + settings.height_offset),
				max_height
			) + 1

	var area := AABB(
		# starting point
		Vector3i(0, settings.min_height, 0),
		Vector3i(settings.world_size.x, max_height - settings.min_height, settings.world_size.y)
		# size
	)

	_set_grid_area(area)


func _set_chunk_grid(chunk_position: Vector3i) -> void:
	_set_grid_area(AABB(chunk_position * chunk_size, chunk_size))


func _set_grid_area(area: AABB) -> void:
	for x in range(area.position.x, area.end.x):
		if not settings.infinite:
			if x < 0 or x > settings.world_size.x:
				continue

		for z in range(area.position.z, area.end.z):
			if not settings.infinite:
				if z < 0 or z > settings.world_size.y:
					continue

			var height = floor(settings.noise.get_noise_2d(x, z) * settings.height_intensity + settings.height_offset)
			if settings.falloff_enabled and settings.falloff_map and not settings.infinite:
				height = ((height + 1) * settings.falloff_map.get_value(Vector2i(x, z))) - 1.0

			for y in range(area.position.y, area.end.y):
				if y <= height and y >= settings.min_height:
					grid.set_valuexyz(x, y, z, settings.tile)

				elif y == height + 1 and settings.air_layer:
					grid.set_valuexyz(x, y, z, null)
