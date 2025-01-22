@tool
extends Control


var _selected_generator: GaeaGenerator = null : get = get_selected_generator
var _output_node: GraphNode

@onready var _no_data: Control = $NoData
@onready var _editor: Control = $Editor
@onready var _graph_edit: GraphEdit = %GraphEdit
@onready var _create_node_popup: PopupPanel = %CreateNodePopup


func populate(node: GaeaGenerator) -> void:
	_output_node = null
	if node.data == null:
		_editor.hide()
		_no_data.show()
		_selected_generator = node
	else:
		_editor.show()
		_no_data.hide()
		_selected_generator = node
		if not _selected_generator.data.layer_count_modified.is_connected(_update_output_node):
			_selected_generator.data.layer_count_modified.connect(_update_output_node)
		_load_data.call_deferred()


func unpopulate() -> void:
	_save_data()
	if _selected_generator.data.layer_count_modified.is_connected(_update_output_node):
		_selected_generator.data.layer_count_modified.disconnect(_update_output_node)
	_selected_generator = null
	for child in _graph_edit.get_children():
		if child is GraphNode:
			child.queue_free()


func _on_new_data_button_pressed() -> void:
	_selected_generator.data = GaeaData.new()
	populate(_selected_generator)


func _popup_create_node_menu_at_mouse() -> void:
	_create_node_popup.position = get_global_mouse_position()
	_create_node_popup.popup()


func _on_graph_edit_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			_popup_create_node_menu_at_mouse()


func _add_node(resource: GaeaNodeResource) -> GraphNode:
	var node: GaeaGraphNode = resource.get_scene().instantiate()
	node.resource = resource
	node.generator = get_selected_generator()
	_graph_edit.add_child(node)

	#node.set_generator_reference(_selected_generator)
	node.on_added()
	node.save_requested.connect(_save_data)
	return node


func _add_node_at_mouse(resource: GaeaNodeResource) -> GraphNode:
	var node := _add_node(resource)
	node.set_position_offset((_graph_edit.get_local_mouse_position() + _graph_edit.scroll_offset) / _graph_edit.zoom)
	_save_data.call_deferred()
	return node


func _on_tree_node_selected_for_creation(resource: GaeaNodeResource) -> void:
	_create_node_popup.hide()

	_add_node_at_mouse(resource)


func _on_cancel_create_button_pressed() -> void:
	_create_node_popup.hide()


func _on_generate_button_pressed() -> void:
	_save_data()

	if _selected_generator.random_seed_on_generate:
		_selected_generator.seed = randi()

	_selected_generator.generate()


func _update_output_node() -> void:
	if is_instance_valid(_output_node):
		await _output_node.update_slots()
		await get_tree().process_frame
		_graph_edit.remove_invalid_connections()


func get_selected_generator() -> GaeaGenerator:
	return _selected_generator


func update_connections() -> void:
	for node in _graph_edit.get_children():
		if node is GraphNode:
			node.connections.clear()

	var connections: Array[Dictionary] = _graph_edit.get_connection_list()
	for connection in connections:
		var to_node: GraphNode = _graph_edit.get_node(NodePath(connection.to_node))

		to_node.connections.append(connection)


func _save_data() -> void:
	if not is_instance_valid(_selected_generator):
		return

	_selected_generator.data.node_data.clear()
	_selected_generator.data.resources.clear()
	_selected_generator.data.connections.clear()

	var resources: Array[GaeaNodeResource]
	var connections: Array[Dictionary] = _graph_edit.get_connection_list()
	var node_data: Array[Dictionary]

	for child in _graph_edit.get_children():
		if child is GraphNode:
			resources.append(child.resource)

	for connection in connections:
		var from_node: GraphNode = _graph_edit.get_node(NodePath(connection.from_node))
		var to_node: GraphNode = _graph_edit.get_node(NodePath(connection.to_node))

		connection.from_node = resources.find(from_node.resource)
		connection.to_node = resources.find(to_node.resource)

	for resource in resources:
		node_data.append(resource.node.get_save_data())

	_selected_generator.data.connections = connections
	_selected_generator.data.resources = resources
	_selected_generator.data.node_data = node_data
	_selected_generator.data.scroll_offset = _graph_edit.scroll_offset


func _load_data() -> void:
	_graph_edit.scroll_offset = _selected_generator.data.scroll_offset

	var has_output_node: bool = false
	for idx in _selected_generator.data.resources.size():
		var resource: GaeaNodeResource = _selected_generator.data.resources[idx]
		var node: GraphNode = _add_node(resource)
		var node_data: Dictionary = _selected_generator.data.node_data[idx]

		if resource.is_output:
			has_output_node = true
			_output_node = node

		if is_instance_valid(node):
			node.load_save_data.call_deferred(node_data)

	if not has_output_node:
		_add_node(preload("res://addons/gaea/graph/nodes/output_node_resource.tres"))

	# from_node and to_node are indexes in the resources array
	for connection in _selected_generator.data.connections:
		var from_node: GraphNode = _selected_generator.data.resources[connection.from_node].node
		var to_node: GraphNode = _selected_generator.data.resources[connection.to_node].node

		if to_node.get_input_port_count() <= connection.to_port:
			continue
		_graph_edit.connection_request.emit(from_node.name, connection.from_port, to_node.name, connection.to_port)

	update_connections()


func _on_graph_edit_connection_to_empty(from_node: StringName, from_port: int, release_position: Vector2) -> void:
	_popup_create_node_menu_at_mouse()


func _notification(what: int) -> void:
	if what == NOTIFICATION_EDITOR_PRE_SAVE:
		_save_data()
