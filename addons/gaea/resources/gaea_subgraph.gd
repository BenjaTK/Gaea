@tool
class_name GaeaSubGraph
extends GaeaGraph


func get_input_nodes() -> Dictionary[StringName, GaeaNodeSubGraphInput]:
	var result: Dictionary[StringName, GaeaNodeSubGraphInput]
	for node in get_nodes():
		if node is GaeaNodeSubGraphInput:
			result[get_node_argument(
				node.id, &"name", node.get_argument_default_value(&"name")
			)] = node
	return result



func get_output_nodes() -> Dictionary[StringName, GaeaNodeSubGraphOutput]:
	var result: Dictionary[StringName, GaeaNodeSubGraphOutput]
	for node in get_nodes():
		if node is GaeaNodeSubGraphOutput:
			result[get_node_argument(
				node.id, &"name", node.get_argument_default_value(&"name")
			)] = node
	return result
