@tool
extends GaeaNodeResource
class_name GaeaNodeInput
## Returns different input variables.


enum InputVars {
	WORLD_SIZE,
	AREA_SIZE,
	AREA_POSITION,
	AREA_END
}


func _get_title() -> String:
	return "Input"


func _get_tree_items() -> Array[GaeaNodeResource]:
	var items: Array[GaeaNodeResource]
	for input_type in InputVars.values():
		var item: GaeaNodeResource = get_script().new()
		item.set_default_enum_value_override(0, input_type)
		item.set_tree_name_override(InputVars.find_key(input_type).to_pascal_case())
		items.append(item)

	return items


func _get_enums_count() -> int:
	return 1


func _get_enum_options(_enum_idx: int) -> Dictionary:
	return InputVars


func _on_enum_value_changed(_enum_idx: int, _option_value: int) -> void:
	notify_argument_list_changed()


func _get_output_ports_list() -> Array[StringName]:
	return [&"value"]


func _get_arguments_list() -> Array[StringName]:
	return []


func _get_overridden_output_port_idx(_output_name: StringName) -> int:
	return 0


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	match get_enum_selection(0):
		InputVars.WORLD_SIZE: return GaeaValue.Type.VECTOR3I
		InputVars.AREA_SIZE, InputVars.AREA_POSITION, InputVars.AREA_END: return GaeaValue.Type.VECTOR3
	return GaeaValue.Type.NULL


func _get_data(output_port: StringName, area: AABB, generator_data: GaeaData) -> Variant:
	_log_data(output_port, generator_data)

	match get_enum_selection(0):
		InputVars.WORLD_SIZE: return generator_data.generator.world_size
		InputVars.AREA_SIZE: return area.size
		InputVars.AREA_POSITION: return area.position
		InputVars.AREA_END: return area.end

	return null
