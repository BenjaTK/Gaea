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
		Vector2i(settings.world_length, max_height)
	)
	
	_set_grid_area(area)


func _set_chunk_grid(chunk_position: Vector2i) -> void:
	_set_grid_area(Rect2i(chunk_position * CHUNK_SIZE, Vector2i(CHUNK_SIZE, CHUNK_SIZE)))


func _set_grid_area(area: Rect2i) -> void:
	for x in range(area.position.x, area.end.x):
		var height = floor(settings.noise.get_noise_1d(x) * settings.height_intensity + settings.height_offset)
		for y in range(area.position.y, area.end.y):
			if y > -height:
				grid[Vector2(x, y)] = settings.tile
