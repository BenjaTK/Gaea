extends TextureRect


var object: Object


func _ready() -> void:
	custom_minimum_size = Vector2(128, 128)
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	focus_mode = Control.FOCUS_NONE
	custom_minimum_size = get_combined_minimum_size()
	tooltip_text = "White is where the tiles will be placed, black is where they won't."


func update() -> void:
	var noise = object.get("noise") as FastNoiseLite
	if not is_instance_valid(noise):
		texture = null
		return

	var image = noise.get_seamless_image(128, 128)
	for x in image.get_size().x:
		for y in image.get_size().y:
			if noise.get_noise_2d(x, y) > object.get("threshold"):
				image.set_pixel(x, y, Color.WHITE)
			else:
				image.set_pixel(x, y, Color.BLACK)
	texture = ImageTexture.create_from_image(image)
