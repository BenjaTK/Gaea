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

	for cell in passed_data:
		var value: float = passed_data[cell]
		if value < get_arg("min", generator_data) or value > get_arg("max", generator_data):
			grid[cell] = null
		else:
			grid[cell] = material.get_resource()

	return grid
