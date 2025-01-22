@tool
extends GaeaNodeResource


@export_enum("Sum", "Multiplication", "Division") var operation: int = 0


func get_data(output_port: int, area: AABB, generator_data: GaeaData) -> Dictionary:
	var data_input_resource: GaeaNodeResource = generator_data.resources[get_connected_resource_idx(0)]
	var passed_data: Dictionary = data_input_resource.get_data(
		get_connected_port_to(0),
		area, generator_data
	)

	for cell in passed_data:
		passed_data[cell] = _get_new_value(passed_data[cell])

	return passed_data


func _get_new_value(original: float) -> float:
	match operation:
		0: return original + get_arg("value")
		1: return original * get_arg("value")
		2: return original / get_arg("value")
	return original
