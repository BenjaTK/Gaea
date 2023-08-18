@tool
@icon("heightmap_generator_2d.svg")
class_name HeightmapGenerator2D
extends GaeaGenerator
## Generates terrain using a heightmap from a noise texture.
##
## [b]Note:[/b] Needs optimization.

@export var settings: HeightmapGenerator2DSettings


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

	if settings.random_noise_seed:
		settings.noise.seed = randi()
	
	erase_chunk(chunk_position)
	_set_chunk_grid(chunk_position)
	_apply_modifiers_chunk(settings.modifiers, chunk_position)
	_draw_tiles_chunk(chunk_position)


func _set_grid() -> void:
	for x in settings.world_length:
		var height = floor(settings.noise.get_noise_1d(x) * settings.height_intensity + settings.height_offset)

		for y in range(0, -height - 1, -1):
			grid[Vector2(x, y)] = settings.tile


func _set_chunk_grid(chunk_position: Vector2i) -> void:
	for x in get_chunk_range(chunk_position.x):
		var height = floor(settings.noise.get_noise_1d(x) * settings.height_intensity + settings.height_offset)
		for y in get_chunk_range(chunk_position.y):
			if y > -height:
				grid[Vector2(x, y)] = settings.tile
