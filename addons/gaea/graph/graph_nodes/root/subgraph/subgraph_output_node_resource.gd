@tool
class_name GaeaNodeSubGraphOutput
extends GaeaNodeResource
## Adds an input argument to the subgraph node.


func _get_title() -> String:
	return "Out"


func _get_description() -> String:
	return "Adds an input argument to the subgraph node."


func _get_enums_count() -> int:
	return 1


func _get_enum_options(_idx: int) -> Dictionary:
	var wireable_types: Array = GaeaValue.get_wireable_types()
	var dict: Dictionary
	for type in wireable_types:
		dict[GaeaValue.Type.find_key(type)] = type
	return dict


func _on_enum_value_changed(_enum_idx: int, _option_value: int) -> void:
	notify_argument_list_changed()


# List of all the arguments, preferably in &"snake_case".
func _get_arguments_list() -> Array[StringName]:
	return [&"name", &"value"]


func _get_argument_type(arg_name: StringName) -> GaeaValue.Type:
	if arg_name == &"name":
		return GaeaValue.Type.VARIABLE_NAME
	return get_type()


func _get_argument_default_value(arg_name: StringName) -> Variant:
	if arg_name == &"name":
		return get_title()
	return GaeaValue.get_default_value(get_argument_type(arg_name))


# List of all the outputs, preferably in &"snake_case"
func _get_output_ports_list() -> Array[StringName]:
	return []


func _get_output_port_type(output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.NULL


func get_type() -> GaeaValue.Type:
	return get_enum_selection(0)


func _get_data(_output_port: StringName, graph: GaeaGraph, pouch: GaeaGenerationPouch) -> Variant:
	return _get_arg(&"value", graph, pouch)
