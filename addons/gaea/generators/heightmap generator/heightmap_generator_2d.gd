@tool
@icon("heightmap_generator_2d.svg")
class_name HeightmapGenerator2D extends GaeaGenerator


@export var settings: HeightmapGenerator2DSettings


func generate() -> void:
	if Engine.is_editor_hint() and not preview:
		return

	if not settings or not is_instance_valid(tileMap) or not defaultTileInfo:
		return

	if settings.randomNoiseSeed:
		settings.noise.seed = randi()

	erase(clearTilemapOnGeneration)
	_set_grid()
	_apply_modifiers(settings.modifiers)
	_draw_tiles()


func _set_grid() -> void:
	for x in settings.worldLength:
		var height = floor(settings.noise.get_noise_1d(x) * settings.heightIntensity + settings.heightOffset)
		prints(height, settings.noise.get_noise_1d(x), settings.heightIntensity, settings.heightOffset)

		for y in range(0, -height - 1, -1):
			grid[Vector2(x, y)] = defaultTileInfo
