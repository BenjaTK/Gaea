@tool
class_name NoiseGenerator extends GaeaGenerator
## Takes a Dictionary of thresholds and tiles to generate organic terrain with different tiles for different heights.


@export var settings: NoiseGeneratorSettings


func generate() -> void:
	if Engine.is_editor_hint() and not preview:
		return

	super.generate()

	if not settings:
		push_error("%s doesn't have a settings resource" % name)
		return

	if settings.randomNoiseSeed:
		settings.noise.seed = randi()

	erase(clearTilemapOnGeneration)
	_set_grid()
	_apply_modifiers(settings.modifiers)
	_draw_tiles()


func _set_grid() -> void:
	for x in settings.worldSize.x:
		for y in settings.worldSize.y:
			var noise = settings.noise.get_noise_2d(x, y)
			for threshold in settings.tiles:
				if not (threshold is float) or not (settings.tiles[threshold] is TileInfo):
					continue
				if noise > threshold:
					grid[Vector2(x, y)] = settings.tiles[threshold]
					break
