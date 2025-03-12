@tool
extends GaeaNodeResource


func get_data(output_port: int, area: AABB, generator_data: GaeaData) -> Dictionary:
	var data_input_resource: GaeaNodeResource = generator_data.resources[get_connected_resource_idx(0)]
	var passed_data: Dictionary = data_input_resource.get_data(
		get_connected_port_to(0),
		area, generator_data
	)
	var material: GaeaMaterial = null

	if get_connected_resource_idx(1) != -1:
		var material_input_resource: GaeaNodeResource = generator_data.resources[get_connected_resource_idx(1)]
		if is_instance_valid(material_input_resource):
			material = material_input_resource.get_data(
				get_connected_port_to(1),
				area, generator_data
			).value
	var grid: Dictionary
	var range: Dictionary = get_arg("range", generator_data)
	prints("Range", range)

	for cell in passed_data:
		var value: float = passed_data[cell]
		if value < range.get("min", 0.0) or value > range.get("max", 0.0):
			grid[cell] = null
		else:
			if is_instance_valid(material):
				grid[cell] = material.get_resource()
			else:
				grid[cell] = null

	return grid
