@tool
class_name GaeaGraphNodeParameter
extends Control

@export var add_input_slot: bool = true
@export var input_type: GaeaGraphNode.SlotTypes
@export var connection_idx: int = 0

var resource: GaeaNodeArgument
var _input_idx: int = 0
var _graph_node: GaeaGraphNode

signal param_value_changed(new_value: Variant)

@onready var label: Label = $Label


func _ready() -> void:
	if get_parent() is GaeaGraphNode:
		_graph_node = get_parent()
		param_value_changed.connect(_graph_node._on_param_value_changed.bind(self, resource.name))

		await _graph_node.ready

		var parent: Node = get_parent()
		_input_idx = get_index()

		_graph_node.set_slot(
			_input_idx,
			add_input_slot, input_type, _graph_node.get_color_from_type(input_type),
			false, -1, Color.WHITE,
		)

	set_label_text(resource.name.capitalize())


func get_param_value() -> Variant:
	if add_input_slot:
		var _connected_node: GaeaGraphNode = _graph_node.get_connected_node(_input_idx)
		prints(_connected_node, "is connected to", resource.name)
		if _connected_node != null:
			return _connected_node.resource.get_data(
				_graph_node.resource.get_connected_port_to(_input_idx), Rect2i(), _graph_node.generator.data
			).value
	return null


func set_param_value(new_value: Variant) -> void:
	pass


func set_label_text(new_text: String) -> void:
	label.text = new_text


#func _on_graph_node_connections_updated() -> void:
	#var _connected_node: GaeaGraphNode = _graph_node.get_connected_input_node(connection_idx)
	#if _connected_node != null:
		#hide()
	#else:
		#show()
	#param_value_changed.emit()
