@tool
class_name HeightmapGenerator2D extends GaeaGenerator


@export var settings: HeightmapGenerator2DSettings


func generate() -> void:
	if Engine.is_editor_hint() and not preview:
		return

	if not settings or not is_instance_valid(tileMap):
		return

	settings.noise.seed = randi()

	erase()
	_set_grid()
	_draw_tiles()


func _set_grid() -> void:
	for x in settings.worldSize.x:
		print(settings.noise.get_noise_1d(x))
		var height = floor(settings.noise.get_noise_1d(x) * settings.heightIntensity + settings.heightOffset)

		for y in range(-1, -height - 1, -1):
			grid[Vector2(x, y)] = defaultTileInfo
