@tool
extends GaeaNodeResource


func get_data(output_port: int, area: AABB, generator_data: GaeaData) -> Dictionary:
	var data_input_resource: GaeaNodeResource = generator_data.resources[get_connected_resource_idx(0)]
	var passed_data: Dictionary = data_input_resource.get_data(
		get_connected_port_to(0),
		area, generator_data
	)
	var tile_info: GaeaMaterial = null

	if get_connected_resource_idx(1) != -1:
		var tile_info_input_resource: GaeaNodeResource = generator_data.resources[get_connected_resource_idx(1)]
		if is_instance_valid(tile_info_input_resource):
			tile_info = tile_info_input_resource.get_data(
				get_connected_port_to(1),
				area, generator_data
			).value
	var grid: Dictionary

	for x in get_axis_range(Axis.X, area):
		for y in get_axis_range(Axis.Y, area):
			for z in get_axis_range(Axis.Z, area):
				var value: float = passed_data[Vector3i(x, y, z)]
				if value < get_arg("min", generator_data) or value > get_arg("max", generator_data):
					grid[Vector3i(x, y, z)] = null
				else:
					grid[Vector3i(x, y, z)] = tile_info

	return grid
