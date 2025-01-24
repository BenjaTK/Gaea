@tool
extends GaeaNodeResource


func get_data(output_port: int, area: AABB, generator_data: GaeaData) -> Dictionary:
	var map_one_resource: GaeaNodeResource = generator_data.resources[get_connected_resource_idx(0)]
	var map_one_data: Dictionary = map_one_resource.get_data(
		get_connected_port_to(0),
		area, generator_data
	).duplicate()

	var map_two_resource: GaeaNodeResource = generator_data.resources[get_connected_resource_idx(1)]
	var map_two_data: Dictionary = map_two_resource.get_data(
		get_connected_port_to(1),
		area, generator_data
	)

	var grid: Dictionary
	for cell in map_one_data:
		if map_two_data.has(cell) and map_two_data[cell] != null:
			grid[cell] = map_two_data.get(cell)
		else:
			grid[cell] = map_one_data.get(cell)

	return grid
