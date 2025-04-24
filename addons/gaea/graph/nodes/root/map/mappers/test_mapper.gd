@tool
extends GaeaNodeResource
class_name GaeaNodeTestMapper
## Abstract class used for mapper nodes. Can be overriden to customize behavior,
## otherwise maps all non-empty cells in [param data] to [param material].


enum TestEnum1 {
	FIRST_OPTION = 4,
	SECOND_OPTION = 5,
	THIRD_OPTION = 7
}

enum TestEnum2 {
	OPTION_FIRST,
	OPTION_SECOND,
	OPTION_THIRD
}


func _get_tree_items() -> Array[GaeaNodeResource]:
	var array: Array[GaeaNodeResource]

	for i in TestEnum1.values():
		var item: GaeaNodeResource = get_script().new()
		item.set_default_enum_value_override(0, i)
		item.set_tree_name_override(_get_title() + "%d" % i)
		array.append(item)

	return array

func _get_title() -> String:
	return "TEST MAPPER. DELETE THIS"


func _get_description() -> String:
	return "ENUMS RIGHT NOW: %d and %d" % [get_enum_selection(0), get_enum_selection(1)]


func _get_enums_count() -> int:
	return 2


func _get_enum_options(enum_idx: int) -> Dictionary:
	match enum_idx:
		0: return TestEnum1
		1: return TestEnum2
	return super(enum_idx)


func _get_arguments_list() -> Array[StringName]:
	var _args: Array[StringName] = [&"data_or_map"]
	if get_enum_selection(1) == TestEnum2.OPTION_FIRST:
		_args.append_array([&"a", &"b", &"c", &"d", &"f"])
	else:
		_args.append(&"material")
	return _args


func _get_argument_type(arg_name: StringName) -> GaeaValue.Type:
	match arg_name:
		&"data_or_map":
			return (GaeaValue.Type.DATA if get_enum_selection(0) == TestEnum1.FIRST_OPTION else GaeaValue.Type.MAP)
		&"material":
			return GaeaValue.Type.MAP
		_:
			return GaeaValue.Type.BOOLEAN

	return super(arg_name)


func _get_output_ports_list() -> Array[StringName]:
	if get_enum_selection(1) == TestEnum2.OPTION_THIRD:
		return [&"test"]
	return [&"map"]


func _get_output_port_type(output_name: StringName) -> GaeaValue.Type:
	return (GaeaValue.Type.MAP if output_name == &"map" else GaeaValue.Type.FLOAT)


func _get_required_arguments() -> Array[StringName]:
	return [&"data_or_map"]


func _get_data(output_port: StringName, area: AABB, generator_data: GaeaData) -> Dictionary:
	_log_data(output_port, generator_data)

	var grid_data = _get_arg(&"data_or_map", area, generator_data)
	var material: GaeaMaterial = TileMapMaterial.new()

	var grid: Dictionary[Vector3i, GaeaMaterial]

	for cell in grid_data:
		if is_instance_valid(material) and _passes_mapping(grid_data, cell, area, generator_data):
			grid[cell] = material.get_resource()

	return grid


@warning_ignore("unused_parameter")
func _passes_mapping(grid_data: Dictionary, cell: Vector3i, area: AABB, generator_data: GaeaData) -> bool:
	return grid_data.get(cell) > 0.5


func _on_enum_value_changed(_enum_idx: int, _option_value: int) -> void:
	notify_argument_list_changed()
