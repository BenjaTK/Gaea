@tool
extends GaeaGraphNode


func execute() -> void:
	var map_input_node: GaeaGraphNode = get_connected_input_node(0)
	var data: Dictionary = map_input_node.get_data(get_from_port(0))
	_generator.generation_finished.emit(data)
