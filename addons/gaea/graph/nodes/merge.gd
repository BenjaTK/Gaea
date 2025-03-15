@tool
extends GaeaNodeResource


func get_data(output_port: int, area: AABB, generator_data: GaeaData) -> Dictionary:
	var grids: Array[Dictionary] = []
	for i: int in input_slots.size():
		if get_connected_resource_idx(i) == -1:
			continue

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

	for x in get_axis_range(Axis.X, area):
		for y in get_axis_range(Axis.Y, area):
			for z in get_axis_range(Axis.Z, area):
				var cell: Vector3i = Vector3i(x, y, z)
				for subgrid: Dictionary in grids:
					if subgrid.get(cell) != null:
						grid.set(cell, subgrid.get(cell))

	return grid
