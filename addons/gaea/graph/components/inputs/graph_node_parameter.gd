@tool
extends Control

@export var add_input_slot: bool = true
@export var input_type: GaeaGraphNode.SlotTypes
@export var connection_idx: int = 0

var _input_idx: int = 0
var _graph_node: GaeaGraphNode

signal param_value_changed


func _ready() -> void:
	if owner is GaeaGraphNode:
		_graph_node = owner
		_graph_node.connections_updated.connect(_on_graph_node_connections_updated)

		await owner.ready

		var parent: Node = get_parent()
		_input_idx = get_index()
		if parent != owner and parent.get_parent() == owner:
			_input_idx = parent.get_index()

		_graph_node.set_slot(
			_input_idx,
			add_input_slot, input_type, _graph_node.get_color_from_type(input_type),
			false, -1, Color.WHITE,
		)
		param_value_changed.connect(owner.request_save)


func get_param_value() -> Variant:
	if add_input_slot:
		var _connected_node: GaeaGraphNode = _graph_node.get_connected_input_node(connection_idx)
		if _connected_node  != null:
			return _connected_node.get_data(_graph_node.get_from_port(connection_idx)).value
	return null


func set_param_value(new_value: Variant) -> void:
	pass



func _on_graph_node_connections_updated() -> void:
	var _connected_node: GaeaGraphNode = _graph_node.get_connected_input_node(connection_idx)
	if _connected_node != null:
		hide()
	else:
		show()
	param_value_changed.emit()
