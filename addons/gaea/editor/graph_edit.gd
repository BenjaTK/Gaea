@tool
extends GraphEdit


signal request_connection_update


func _on_delete_nodes_request(nodes: Array[StringName]) -> void:
	for node_name in nodes:
		var node: GraphElement = get_node(NodePath(node_name))
		if node is GaeaGraphNode:
			if node.resource.is_output:
				continue

			for connection in node.connections:
				disconnect_node(connection.from_node, connection.from_port, connection.to_node, connection.to_port)
			node.on_removed()
			#remove_child(node)
		node.queue_free()
	request_connection_update.emit.call_deferred()


func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	connect_node(from_node, from_port, to_node, to_port)
	request_connection_update.emit()

	get_node(NodePath(from_node)).notify_connections_updated.call_deferred()
	get_node(NodePath(to_node)).notify_connections_updated.call_deferred()


func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	disconnect_node(from_node, from_port, to_node, to_port)
	request_connection_update.emit()

	get_node(NodePath(from_node)).notify_connections_updated.call_deferred()
	get_node(NodePath(to_node)).notify_connections_updated.call_deferred()


func remove_invalid_connections() -> void:
	for connection in get_connection_list():
		var to_node: GraphNode = get_node(NodePath(connection.to_node))
		var from_node: GraphNode = get_node(NodePath(connection.from_node))

		if not is_instance_valid(from_node) or not is_instance_valid(to_node):
			disconnect_node(connection.from_node, connection.from_port, connection.to_node, connection.to_port)
			continue

		if to_node.get_input_port_count() <= connection.to_port:

			disconnect_node(connection.from_node, connection.from_port, connection.to_node, connection.to_port)
			continue

		if from_node.get_output_port_count() <= connection.from_port:
			disconnect_node(connection.from_node, connection.from_port, connection.to_node, connection.to_port)
			continue


func get_selected() -> Array:
	return get_children().filter(func(child: Node) -> bool:
		return child is GaeaGraphNode and child.selected
	)


func get_selected_names() -> Array[StringName]:
	var selected := get_selected()
	var array: Array[StringName]
	for node: Node in selected:
		array.append(node.name)
	return array


func _on_graph_elements_linked_to_frame_request(elements: Array, frame: StringName) -> void:
	for element in elements:
		attach_graph_element_to_frame(element, frame)
