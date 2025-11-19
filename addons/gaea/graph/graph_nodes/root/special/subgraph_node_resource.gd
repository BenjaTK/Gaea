@tool
class_name GaeaNodeSubGraph
extends GaeaNodeResource
## Node description.


var subgraph: GaeaSubGraph


func _get_title() -> String:
	return "SubGraph"


func _get_description() -> String:
	return "Node description."


func _on_added_to_graph(graph: GaeaGraph) -> void:
	subgraph = GaeaSubGraph.new()
	graph.set_node_data_value(id, &"subgraph", subgraph)


func _get_scene() -> PackedScene:
	return load("uid://i4amiqtbm0bi")


# List of all the arguments, preferably in &"snake_case".
func _get_arguments_list() -> Array[StringName]:
	return subgraph.get_input_nodes().keys()


func _get_argument_type(arg_name: StringName) -> GaeaValue.Type:
	return subgraph.get_input_nodes()[arg_name].get_type()


func _get_argument_default_value(arg_name: StringName) -> Variant:
	return subgraph.get_input_nodes()[arg_name].get_argument_default_value(arg_name)


func _is_input_only(_arg_name: StringName) -> bool:
	return true

# List of all the outputs, preferably in &"snake_case"
func _get_output_ports_list() -> Array[StringName]:
	return subgraph.get_output_nodes().keys()


func _get_output_port_type(output_name: StringName) -> GaeaValue.Type:
	return subgraph.get_output_nodes()[output_name].get_type()


func _get_data(output_port: StringName, graph: GaeaGraph, pouch: GaeaGenerationPouch) -> Variant:
	for in_node in subgraph.get_input_nodes().values():
		in_node.parent_node = self
		in_node.parent_graph = graph

	var output_node: GaeaNodeSubGraphOutput = subgraph.get_output_nodes().get(output_port)
	return output_node.traverse(&"value", subgraph, pouch).value


func _load_save_data(saved_data: Dictionary) -> void:
	subgraph = saved_data.get(&"subgraph", null)
	super(saved_data)


func _get_custom_saved_data() -> Dictionary[StringName, Variant]:
	return {&"subgraph": subgraph}
