@tool
class_name GaeaEditorNodePreview
extends MarginContainer

var selected_output: StringName = &""
var node: GaeaEditorGraphNode
var slider_container: HBoxContainer
var slider: HSlider
var slider_label: SpinBox
var texture_rect: TextureRect
var label: Label


func _init(parent_node) -> void:
	node = parent_node


func _ready() -> void:
	if is_part_of_edited_scene():
		return

	texture_rect = TextureRect.new()
	texture_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(texture_rect)
	texture_rect.expand_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT

	label = Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.custom_minimum_size.y = 128.0

	label.add_theme_font_size_override(&"font_size", 32)
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(label)

	await get_tree().process_frame

	texture_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	slider_container = HBoxContainer.new()
	slider_container.visible = false

	slider_label = SpinBox.new()
	slider_label.step = 0.01
	slider_label.min_value = 0.0
	slider_label.max_value = 1.0

	slider = HSlider.new()
	slider.step = 0.001
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	slider_label.value_changed.connect(slider.set_value_no_signal)
	slider_label.value_changed.connect(update.unbind(1))
	slider.value_changed.connect(update.unbind(1))
	slider.value_changed.connect(slider_label.set_value_no_signal)
	slider.allow_greater = true
	slider.allow_lesser = true

	slider_label.allow_greater = true
	slider_label.allow_lesser = true

	slider_container.add_child(slider)
	slider_container.add_child(slider_label)

	get_parent().add_child(slider_container)

	var preview_resolution: Vector3i = node.graph_edit.graph.preview_chunk_size

	texture_rect.texture = ImageTexture.create_from_image(
		Image.create_empty(preview_resolution.x, preview_resolution.y, true, Image.FORMAT_RGBA8)
	)


func toggle(for_output: StringName) -> void:
	if not get_parent().visible:
		get_parent().show()
		if is_instance_valid(slider_container):
			slider_container.visible = (
				node.resource.get_output_port_type(for_output) == GaeaValue.Type.SAMPLE
			)
		selected_output = for_output
		update()
	else:
		if selected_output == for_output:
			selected_output = &""
		get_parent().hide()

	node.auto_shrink.call_deferred()


func update() -> void:
	if not is_visible_in_tree():
		return

	var graph: GaeaGraph = node.graph_edit.graph
	var resolution: Vector2i = Vector2i(graph.preview_chunk_size.x, graph.preview_chunk_size.y)
	var preview_max_sim: int = GaeaEditorSettings.get_preview_max_simulation_size()
	var sim_size: Vector3 = Vector3(resolution.x, resolution.y, 1).min(Vector3(preview_max_sim, preview_max_sim, preview_max_sim))
	var generation_settings = GaeaGenerationSettings.new()
	generation_settings.world_size = sim_size
	generation_settings.random_seed_on_generate = false
	generation_settings.seed = graph.preview_seed

	var pouch: GaeaGenerationPouch = GaeaGenerationPouch.new(generation_settings, AABB(Vector3.ZERO, sim_size))
	var data: Variant = node.resource.traverse(selected_output, pouch).get("value")
	pouch.clear_all_cache()


	if data is GaeaValue.GridType:
		texture_rect.texture = create_texture(data, sim_size, resolution)
		label.text = ""
	else:
		texture_rect.texture = null
		if data is float and node.resource.get_output_port_type(selected_output) == GaeaValue.Type.INT:
			data = int(data)

		label.text = str(data).capitalize()




func create_texture(data: GaeaValue.GridType, sim_size: Vector3, resolution: Vector2i) -> Texture:
	var sim_center: Vector3i = sim_size * 0.5
	var res_center: Vector3i = Vector3i(resolution.x, resolution.y, 0) * 0.5
	var sim_offset := sim_center.max(res_center) - sim_center.min(res_center)

	var image: Image = Image.create_empty(resolution.x, resolution.y, true, Image.FORMAT_RGBA8)
	for x: int in resolution.x:
		for y: int in resolution.y:
			var color: Color
			var value = data.get_cell(Vector3i(x, y, 0) + sim_offset)
			if value == null:
				continue
			match node.resource.get_output_port_type(selected_output):
				GaeaValue.Type.SAMPLE:
					if typeof(value) != TYPE_FLOAT or is_nan(value):
						continue
					color = Color(value, value, value, 1.0 if value >= slider.value else 0.0)
				GaeaValue.Type.MAP:
					if value is not GaeaMaterial or not is_instance_valid(value):
						continue
					color = value.preview_color
			image.set_pixelv(Vector2i(x, y), color)

	return ImageTexture.create_from_image(image)
