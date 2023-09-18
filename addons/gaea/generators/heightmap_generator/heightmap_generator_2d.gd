@tool
@icon("heightmap_generator_2d.svg")
class_name HeightmapGenerator2D
extends ChunkAwareGenerator
## Generates terrain using a heightmap from a noise texture.
## @tutorial(Generators): https://benjatk.github.io/Gaea/#/generators/
## @tutorial(HeightmapGenerator): https://benjatk.github.io/Gaea/#/generators/heightmap

@export var settings: HeightmapGenerator2DSettings


func _ready() -> void:
	if settings.random_noise_seed:
		settings.noise.seed = randi()

	super()


func generate() -> void:
	if Engine.is_editor_hint() and not preview:
		return

	if not settings:
		push_error("%s doesn't have a settings resource" % name)
		return

	if settings.random_noise_seed:
		settings.noise.seed = randi()

	erase()
	_set_grid()
	_apply_modifiers(settings.modifiers)

	grid_updated.emit()


func generate_chunk(chunk_position: Vector2i) -> void:
	if Engine.is_editor_hint() and not preview:
		return

	if not settings:
		push_error("%s doesn't have a settings resource" % name)
		return

	erase_chunk(chunk_position)
	_set_chunk_grid(chunk_position)
	_apply_modifiers_chunk(settings.modifiers, chunk_position)

	generated_chunks.append(chunk_position)

	chunk_updated.emit(chunk_position)


func _set_grid() -> void:
	var max_height: int = 0
	for x in range(settings.world_length):
		max_height = maxi(
			floor(settings.noise.get_noise_1d(x) * settings.height_intensity + settings.height_offset),
			max_height
		)

	var area := Rect2i(
		# starting point
		Vector2i(0, -max_height),
		# size
		Vector2i(settings.world_length, max_height - settings.min_height)
	)

	_set_grid_area(area)


func _set_chunk_grid(chunk_position: Vector2i) -> void:
	_set_grid_area(Rect2i(chunk_position * chunk_size, Vector2i(chunk_size, chunk_size)))


func _set_grid_area(area: Rect2i) -> void:
	for x in range(area.position.x, area.end.x):
		if not settings.infinite:
			if x < 0 or x > settings.world_length:
				continue

		var height = floor(settings.noise.get_noise_1d(x) * settings.height_intensity + settings.height_offset)
		for y in range(area.position.y, area.end.y):
			if y > -height and y <= -settings.min_height:
				grid[Vector2(x, y)] = settings.tile
