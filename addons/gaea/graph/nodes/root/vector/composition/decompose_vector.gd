@tool
extends GaeaNodeResource
class_name GaeaNodeDecomposeVector
## Decomposes vector to floats.

enum EnumList {
	InputVectorType
}

enum VectorType {
	VECTOR2 = GaeaValue.Type.VECTOR2,
	VECTOR3 = GaeaValue.Type.VECTOR3,
	VECTOR2I = GaeaValue.Type.VECTOR2I,
	VECTOR3I = GaeaValue.Type.VECTOR3I,
}


func _get_vector_type_name() -> String:
	return VectorType.find_key(get_enum_selection(EnumList.InputVectorType))


func _get_title() -> String:
	return "VectorDecompose"


func _get_description() -> String:
	return "Decomposes a %s into %d floats." % [_get_vector_type_name().capitalize(), _get_output_ports_list().size()]


#region Enum
func _get_enums_count() -> int:
	return EnumList.size()


func _get_enum_options(enum_idx: int) -> Dictionary:
	match enum_idx:
		EnumList.InputVectorType: return VectorType
	return {}


func _get_enum_option_display_name(enum_idx: int, option_value: int) -> String:
	return super(enum_idx, option_value).replace(" ", "")


func _on_enum_value_changed(_enum_idx: int, _option_value: int) -> void:
	notify_argument_list_changed()
	notify_property_list_changed()
#endregion


#region Arguments
func _get_arguments_list() -> Array[StringName]:
	return [&"vector"]


@warning_ignore("unused_parameter")
func _get_argument_display_name(arg_name: StringName) -> String:
	return ""


@warning_ignore("unused_parameter")
func _get_argument_type(arg_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type[_get_vector_type_name()]
#endregion


#region Outputs
func _get_output_ports_list() -> Array[StringName]:
	match get_enum_selection(EnumList.InputVectorType):
		VectorType.VECTOR2, VectorType.VECTOR2I:
			return [&"x", &"y"]
		VectorType.VECTOR3, VectorType.VECTOR3I:
			return [&"x", &"y", &"z"]
	return []


func _get_output_port_display_name(output_name: StringName) -> String:
	return output_name


@warning_ignore("unused_parameter")
func _get_output_port_type(output_name: StringName) -> GaeaValue.Type:
	return (GaeaValue.Type.FLOAT if get_enum_selection(0) in [VectorType.VECTOR2, VectorType.VECTOR3] else GaeaValue.Type.INT)
#endregion


func _get_tree_items() -> Array[GaeaNodeResource]:
	var array: Array[GaeaNodeResource] = []

	for i in VectorType.values():
		var item: GaeaNodeResource = get_script().new()
		item.set_default_enum_value_override(EnumList.InputVectorType, i)
		item.set_tree_name_override(
			_get_enum_option_display_name(EnumList.InputVectorType, i) + "Decompose"
		)
		array.append(item)

	return array


func _get_data(output_port: StringName, area: AABB, generator_data: GaeaData) -> float:
	_log_data(output_port, generator_data)
	return _get_arg(&"vector", area, generator_data)[output_port]
