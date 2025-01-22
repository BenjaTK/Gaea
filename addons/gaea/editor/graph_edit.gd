@tool
extends GraphEdit


signal request_connection_update


func _on_delete_nodes_request(nodes: Array[StringName]) -> void:
	for node_name in nodes:
		var node: GraphNode = get_node(NodePath(node_name))
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


func _on_node_selected(node: Node) -> void:
	print(node.connections)
