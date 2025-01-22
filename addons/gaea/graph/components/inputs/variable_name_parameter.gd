@tool
extends GaeaGraphNodeParameter


@onready var line_edit: LineEdit = $LineEdit



func _ready() -> void:
	await super()
	if not is_instance_valid(resource):
		return

	line_edit.text_changed.connect(param_value_changed.emit)
	_graph_node.set_slot_enabled_right(0, true)
	_graph_node.set_slot_type_right(0, _graph_node.resource.output_type)
	_graph_node.set_slot_color_right(0, _graph_node.get_color_from_type(_graph_node.resource.output_type))


func get_param_value() -> String:
	if super() != null:
		return super()
	return line_edit.text


func set_param_value(new_value: Variant) -> void:
	line_edit.text = new_value
