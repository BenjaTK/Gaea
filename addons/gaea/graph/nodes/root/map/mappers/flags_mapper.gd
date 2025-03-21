@tool
extends GaeaNodeResource


func get_data(output_port: int, area: AABB, generator_data: GaeaData) -> Dictionary[Vector3i, GaeaMaterial]:
	if get_connected_resource_idx(0) == -1:
		return {}

	var data_input_resource: GaeaNodeResource = generator_data.resources.get(get_connected_resource_idx(0))
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
	var grid: Dictionary[Vector3i, GaeaMaterial]
	var flags: Array = get_arg("match_flags", generator_data)
	var exclude_flags: Array = get_arg("exclude_flags", generator_data)
	var match_all: bool = get_arg("match_all", generator_data)

	for cell in passed_data:
		var value: float = passed_data[cell]
		if (
			(flags.all(_matches_flag.bind(value)) if match_all else flags.any(_matches_flag.bind(value)))
			 and not exclude_flags.any(_matches_flag.bind(value))
			):
			if is_instance_valid(material):
				grid[cell] = material.get_resource()
			else:
				grid[cell] = null
		else:
			grid[cell] = null

	return grid


func _matches_flag(value: float, flag: int) -> bool:
	return roundi(value) & flag
