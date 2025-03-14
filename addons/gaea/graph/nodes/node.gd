@tool
class_name GaeaGraphNode
extends GraphNode


const PreviewTexture = preload("res://addons/gaea/graph/nodes/preview_texture.gd")

enum SlotTypes {
	VALUE_DATA, MAP_DATA, TILE_INFO, VECTOR2, NUMBER, RANGE
}

signal save_requested
signal connections_updated
signal popup_requested

@export var resource: GaeaNodeResource

var generator: GaeaGenerator
var connections: Array[Dictionary]
var preview: PreviewTexture
var preview_container: VBoxContainer
var finished_loading: bool = false


func _ready() -> void:
	initialize()

	set_tooltip_text(GaeaNodeResource.get_formatted_text(resource.description))


func initialize() -> void:
	if not is_instance_valid(resource):
		return

	for input_slot in resource.input_slots:
		add_child(input_slot.get_node())

	for arg in resource.args:
		add_child(arg.get_arg_node())

	for output_slot in resource.output_slots:
		var node: Control = output_slot.get_node()
		add_child(node)
		if output_slot.right_show_preview:
			node.toggle_preview_button.show()
			preview_container = VBoxContainer.new()
			add_child(preview_container)
			preview = PreviewTexture.new()
			preview.output_idx = resource.output_slots.find(output_slot)
			preview.node = self
			preview.resource = resource
			node.toggle_preview_button.toggled.connect(preview_container.set_visible)
			preview_container.add_child(preview)
			preview_container.hide()
			generator.generation_finished.connect(preview.update.unbind(1))

	title = resource.title
	resource.node = self


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_RIGHT and selected:
			popup_requested.emit()
			get_viewport().set_input_as_handled()


func on_added() -> void:
	pass


func get_connected_node(connection_idx: int) -> GraphNode:
	for connection in connections:
		if connection.to_port == connection_idx:
			return get_parent().get_node(NodePath(connection.from_node))
	return null


func get_connected_port(connection_idx: int) -> int:
	for connection in connections:
		if connection.to_port == connection_idx:
			return connection.from_port
	return -1


func get_arg_value(arg_name: String) -> Variant:
	for child in get_children():
		if child is GaeaGraphNodeParameter:
			if child.resource.name.to_lower() == arg_name.to_lower():
				return child.get_param_value()
	return null


func set_arg_value(arg_name: String, value: Variant) -> void:
	for child in get_children():
		if child is GaeaGraphNodeParameter:
			if child.resource.name == arg_name:
				child.set_param_value(value)
				return


func _on_param_value_changed(value: Variant, node: GaeaGraphNodeParameter, param_name: String) -> void:
	if finished_loading:
		save_requested.emit()
		if is_instance_valid(preview):
			preview.update()


func on_removed() -> void:
	pass


func request_save() -> void:
	save_requested.emit()


func notify_connections_updated() -> void:
	connections_updated.emit()


func get_save_data() -> Dictionary:
	for arg in resource.args:
		resource.data[arg.name.to_lower()] = get_arg_value(arg.name)

	var dictionary: Dictionary = {
		"position": position_offset
	}
	return dictionary


func load_save_data(data: Dictionary) -> void:
	position_offset = data.position

	for child in get_children():
		if child is GaeaGraphNodeParameter:
			if resource.data.has(child.resource.name):
				child.set_param_value(resource.data[child.resource.name])

	finished_loading = true


static func get_color_from_type(type: SlotTypes) -> Color:
	match type:
		SlotTypes.VALUE_DATA:
			return Color("9c999e")
		SlotTypes.MAP_DATA:
			return Color("45ffa2")
		SlotTypes.TILE_INFO:
			return Color("ff4545")
		SlotTypes.VECTOR2:
			return Color("a579ff")
		SlotTypes.NUMBER:
			return Color.LIGHT_GRAY
		SlotTypes.RANGE:
			return Color.DIM_GRAY
	return Color.WHITE


func _make_custom_tooltip(for_text: String) -> Object:
	var rich_text_label: RichTextLabel = RichTextLabel.new()
	rich_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	rich_text_label.bbcode_enabled = true
	rich_text_label.text = for_text
	rich_text_label.fit_content = true
	rich_text_label.custom_minimum_size.x = 256.0
	return rich_text_label
