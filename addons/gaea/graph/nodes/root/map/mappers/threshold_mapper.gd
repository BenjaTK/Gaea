@tool
extends GaeaNodeResource


func get_data(output_port: int, area: AABB, generator_data: GaeaData) -> Dictionary[Vector3i, GaeaMaterial]:
	var data_input_resource: GaeaNodeResource = generator_data.resources.get(get_connected_resource_idx(0))
	if not is_instance_valid(data_input_resource):
		return {}

	var passed_data: Dictionary = data_input_resource.get_data(
		get_connected_port_to(0),
		area, generator_data
	)
	var material: GaeaMaterial = null

	if get_connected_resource_idx(1) != -1:
		var material_input_resource: GaeaNodeResource = generator_data.resources.get(get_connected_resource_idx(1))
		if is_instance_valid(material_input_resource):
			material = material_input_resource.get_data(
				get_connected_port_to(1),
				area, generator_data
			).get("value", null)
	var grid: Dictionary[Vector3i, GaeaMaterial]
	var range: Dictionary = get_arg("range", generator_data)

	for cell in passed_data:
		var value = passed_data[cell]
		if value is float and value < range.get("min", 0.0) or value > range.get("max", 0.0):
			grid[cell] = null
		else:
			if is_instance_valid(material):
				grid[cell] = material.get_resource()
			else:
				grid[cell] = null

	return grid
