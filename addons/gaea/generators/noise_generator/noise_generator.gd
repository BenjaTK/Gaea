@tool
@icon("noise_generator.svg")
class_name NoiseGenerator
extends ChunkAwareGenerator
## Takes a Dictionary of thresholds and tiles to generate organic terrain with different tiles for different heights.


@export var settings: NoiseGeneratorSettings


func _ready() -> void:
	if settings.random_noise_seed:
		settings.noise.seed = randi()

	super._ready()


func generate() -> void:
	if Engine.is_editor_hint() and not preview:
		return

	super.generate()

	if not settings:
		push_error("%s doesn't have a settings resource" % name)
		return

	if settings.random_noise_seed:
		settings.noise.seed = randi()

	erase(clear_tilemap_on_generation)
	_set_grid()
	_apply_modifiers(settings.modifiers)
	_draw_tiles()


func generate_chunk(chunk_position: Vector2i) -> void:
	if Engine.is_editor_hint() and not preview:
		return

	super.generate()

	if not settings:
		push_error("%s doesn't have a settings resource" % name)
		return

	erase_chunk(chunk_position)
	_set_grid_chunk(chunk_position)
	_apply_modifiers_chunk(settings.modifiers, chunk_position)
	_draw_tiles_chunk(chunk_position)

	generated_chunks.append(chunk_position)


func _set_grid() -> void:
	_set_grid_area(Rect2i(Vector2i.ZERO, Vector2i(settings.world_size)))


func _set_grid_chunk(chunk_position: Vector2i) -> void:
	_set_grid_area(Rect2i(
		chunk_position * chunk_size,
		Vector2i(chunk_size, chunk_size)
	))


func _set_grid_area(rect: Rect2i) -> void:
	for x in range(rect.position.x, rect.end.x):
		if x < 0 or x > settings.world_size.x:
			continue

		for y in range(rect.position.y, rect.end.y):
			if y < 0 or y > settings.world_size.x:
				continue

			var noise = settings.noise.get_noise_2d(x, y)
			for threshold in settings.tiles:
				if noise > threshold:
					grid[Vector2(x, y)] = settings.tiles[threshold]
					break
