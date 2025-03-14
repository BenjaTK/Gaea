@tool
extends GaeaNodeResource


func get_data(output_port: int, area: AABB, generator_data: GaeaData) -> Dictionary:
	var grids: Array[Dictionary] = []
	for i: int in input_slots.size():
		var resource: GaeaNodeResource = generator_data.resources.get(get_connected_resource_idx(i))
		var data: Dictionary = {}
		if is_instance_valid(resource):
			data = resource.get_data(
				get_connected_port_to(i),
				area, generator_data
			)
		grids.append(data)

	var grid: Dictionary = {}
	if grids.is_empty():
		return grid

	for cell in grids.front():
		for subgrid: Dictionary in grids:
			if subgrid.has(cell) and subgrid.get(cell) != null:
				grid.set(cell, subgrid.get(cell))

	return grid
