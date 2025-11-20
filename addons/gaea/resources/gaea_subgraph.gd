@tool
class_name GaeaSubGraph
extends GaeaGraph


@export var title: String = "SubGraph" : set = set_title
## Input nodes by their name and id.
@export_storage var inputs: Dictionary[int, StringName] : get = get_input_nodes
## Output nodes by their name and id.
@export_storage var outputs: Dictionary[int, StringName] : get = get_output_nodes


func add_node(node: GaeaNodeResource, position: Vector2, id: int = get_next_available_id()) -> int:
	id = super(node, position, id)

	if node is GaeaNodeSubGraphInput:
		inputs.set(
			id, get_node_argument(id, &"name", node.get_argument_default_value(&"name"))
		)
	elif node is GaeaNodeSubGraphOutput:
		outputs.set(
			id, get_node_argument(id, &"name", node.get_argument_default_value(&"name"))
		)

	return id


func remove_node(id: int) -> void:
	inputs.erase(id)
	outputs.erase(id)

	super(id)


func set_node_argument(id: int, arg_name: StringName, value: Variant) -> void:
	super(id, arg_name, value)

	if arg_name == &"name":
		if id in inputs:
			inputs.set(id, value)
		elif id in outputs:
			outputs.set(id, value)



func set_title(value: String) -> void:
	title = value


func get_input_nodes() -> Dictionary[int, StringName]:
	return inputs


func get_output_nodes() -> Dictionary[int, StringName]:
	return outputs
