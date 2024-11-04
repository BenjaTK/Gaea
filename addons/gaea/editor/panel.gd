@tool
extends Control


var _selected_generator: GaeaGenerator = null : get = get_selected_generator

@onready var _no_data: Control = $NoData
@onready var _editor: Control = $Editor
@onready var _graph_edit: GraphEdit = %GraphEdit
@onready var _create_node_popup: PopupPanel = %CreateNodePopup


func populate(node: GaeaGenerator) -> void:
	if node.data == null:
		_editor.hide()
		_no_data.show()
		_selected_generator = node
	else:
		_editor.show()
		_no_data.hide()
		_selected_generator = node
		_load_data.call_deferred()


func unpopulate() -> void:
	_save_data()
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


func _add_node(scene: PackedScene) -> void:
	var node: GraphNode = scene.instantiate()
	_graph_edit.add_child(node)
	node.set_position_offset((_graph_edit.get_local_mouse_position() + _graph_edit.scroll_offset) / _graph_edit.zoom)

	_save_data.call_deferred()
	node.set_generator_reference(_selected_generator)
	node.on_added()
	node.save_requested.connect(_save_data)


func _on_tree_node_selected_for_creation(scene: PackedScene) -> void:
	_create_node_popup.hide()

	_add_node(scene)


func _on_cancel_create_button_pressed() -> void:
	_create_node_popup.hide()


func _on_generate_button_pressed() -> void:
	if _selected_generator.random_seed_on_generate:
		_selected_generator.seed = randi()

	var connections: Array[Dictionary] = _graph_edit.get_connection_list()
	var output_node: GaeaGraphNode
	for node in _graph_edit.get_children():
		if node is GaeaGraphNode:
			node.connections.clear()

	for idx in connections.size():
		var connection: Dictionary = connections[idx]
		var node: GaeaGraphNode = _graph_edit.get_node(NodePath(connection.to_node))

		node.connections.append(connection)
		if node.is_output:
			output_node = node

	output_node.execute()
	_save_data()


func get_selected_generator() -> GaeaGenerator:
	return _selected_generator


func _save_data() -> void:
	if not is_instance_valid(_selected_generator):
		return

	var connections: Array[Dictionary] = _graph_edit.get_connection_list()
	var nodes: Array[Node] = _graph_edit.get_children()
	var scenes: Array[PackedScene]
	var node_data: Array[Dictionary]

	for node in nodes:
		if node is not GaeaGraphNode:
			continue
		scenes.append(load(node.scene_file_path))
		node_data.append(node.get_save_data())

	for connection in connections:
		var from_node: GaeaGraphNode = _graph_edit.get_node(NodePath(connection.from_node))
		var to_node: GaeaGraphNode = _graph_edit.get_node(NodePath(connection.to_node))
		connection.from_node = nodes.find(from_node)
		connection.to_node = nodes.find(to_node)

	_selected_generator.data.connections = connections
	_selected_generator.data.nodes = scenes
	_selected_generator.data.node_data = node_data
	_selected_generator.data.scroll_offset = _graph_edit.scroll_offset


func _load_data() -> void:
	_graph_edit.scroll_offset = _selected_generator.data.scroll_offset
	var scenes = _selected_generator.data.nodes
	for idx in scenes.size():
		var scene = scenes[idx]
		if not is_instance_valid(scene):
			continue

		var node: GaeaGraphNode = scene.instantiate()
		_graph_edit.add_child(node)
		node.load_save_data.call_deferred(_selected_generator.data.node_data[idx])
		node.set_generator_reference(_selected_generator)

	for connection in _selected_generator.data.connections:
		var from_node: GaeaGraphNode = _graph_edit.get_child(connection.from_node)
		var to_node: GaeaGraphNode = _graph_edit.get_child(connection.to_node)
		_graph_edit.connect_node(from_node.name, connection.from_port, to_node.name, connection.to_port)


func _on_graph_edit_connection_to_empty(from_node: StringName, from_port: int, release_position: Vector2) -> void:
	_popup_create_node_menu_at_mouse()


func _notification(what: int) -> void:
	if what == NOTIFICATION_EDITOR_PRE_SAVE:
		_save_data()
