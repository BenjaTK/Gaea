extends TextureRect

var object: Object


func _ready() -> void:
	custom_minimum_size = Vector2(128, 128)
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	focus_mode = Control.FOCUS_NONE
	custom_minimum_size = get_combined_minimum_size()
	tooltip_text = "White is where the generator/modifier will affect the tiles, black is where it won't."


func update() -> void:
	var noise: FastNoiseLite = null
	if object is Modifier or object is NoiseCondition:
		noise = object.get("noise") as FastNoiseLite
	elif object is NoiseGeneratorData:
		noise = object.settings.get("noise")

	if not is_instance_valid(noise):
		texture = null
		return

	var image: Image = noise.get_seamless_image(128, 128)
	for x in image.get_size().x:
		for y in image.get_size().y:
			var value: float = noise.get_noise_2d(x, y)
			if _is_in_threshold(value):
				image.set_pixel(x, y, Color.WHITE)
			else:
				image.set_pixel(x, y, Color.BLACK)
	texture = ImageTexture.create_from_image(image)


func _is_in_threshold(value: float) -> bool:
	if object.get("max") and object.get("min"):
		return value >= object.get("min") and value <= object.get("max")
	return false
