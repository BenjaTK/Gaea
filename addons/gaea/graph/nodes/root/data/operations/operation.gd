@tool
extends GaeaNodeResource


@export_enum("Sum", "Multiplication", "Division") var operation: int = 0


func get_data(output_port: int, area: AABB, generator_data: GaeaData) -> Dictionary[Vector3i, float]:
	var data_input_resource: GaeaNodeResource = generator_data.resources[get_connected_resource_idx(0)]
	if not is_instance_valid(data_input_resource):
		return {}

	var passed_data: Dictionary[Vector3i, float] = data_input_resource.get_data(
		get_connected_port_to(0),
		area, generator_data
	)

	for cell in passed_data:
		passed_data[cell] = _get_new_value(passed_data[cell], generator_data)

	return passed_data


func _get_new_value(original: float, generator_data: GaeaData) -> float:
	match operation:
		0: return original + get_arg("value", generator_data)
		1: return original * get_arg("value", generator_data)
		2:
			var value: float = get_arg("value", generator_data)
			if value == 0.0:
				return original
			return original / value
	return original
