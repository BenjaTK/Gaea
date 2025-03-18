extends TextureRect


const RESOLUTION: Vector2i = Vector2i(64, 64)

var output_idx: int = 0
var resource: GaeaNodeResource
var node: GaeaGraphNode
var scroll_bar: HSlider
var scroll_bar_label: SpinBox


func _ready() -> void:
	expand_mode = EXPAND_FIT_HEIGHT
	stretch_mode = STRETCH_SCALE
	visibility_changed.connect(_on_visibility_changed)

	await get_tree().process_frame

	var scroll_bar_container: HBoxContainer = HBoxContainer.new()

	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	scroll_bar_label = SpinBox.new()
	scroll_bar_label.step = 0.01
	scroll_bar_label.min_value = 0.0
	scroll_bar_label.max_value = 1.0

	scroll_bar = HSlider.new()
	scroll_bar.step = 0.001
	scroll_bar.min_value = 0.0
	scroll_bar.max_value = 1.0
	scroll_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	scroll_bar_label.value_changed.connect(scroll_bar.set_value_no_signal)
	scroll_bar_label.value_changed.connect(update.unbind(1))
	scroll_bar.value_changed.connect(update.unbind(1))
	scroll_bar.value_changed.connect(scroll_bar_label.set_value_no_signal)
	scroll_bar.allow_greater = true
	scroll_bar.allow_lesser = true

	scroll_bar_label.allow_greater = true
	scroll_bar_label.allow_lesser = true

	scroll_bar_container.add_child(scroll_bar)
	scroll_bar_container.add_child(scroll_bar_label)

	get_parent().add_child(scroll_bar_container)

	update()


func _on_visibility_changed() -> void:
	await get_tree().process_frame
	node.size = node.get_combined_minimum_size()
	#update()


func update() -> void:
	node.request_save()
	var resolution: Vector2i = RESOLUTION
	if is_instance_valid(node.generator):
		resolution = resolution.min(Vector2i(node.generator.world_size.x, node.generator.world_size.y))

	var data: Dictionary = resource.get_data(
		output_idx,
		AABB(Vector3.ZERO, Vector3(resolution.x, resolution.y, 1)),
		node.generator.data
	)


	var image: Image = Image.create_empty(resolution.x, resolution.y, true, Image.FORMAT_LA8)
	for x: int in resolution.x:
		for y: int in resolution.y:
			var value: float = data.get(Vector3i(x, y, 0), NAN)
			if is_nan(value):
				continue
			var color: Color = Color(value, value, value, 1.0 if value >= scroll_bar.value else 0.0)
			image.set_pixelv(Vector2i(x, y), color)

	texture = ImageTexture.create_from_image(image)
