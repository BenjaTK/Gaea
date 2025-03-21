@tool
extends GaeaNodeResource


func get_data(output_port: int, area: AABB, generator_data: GaeaData) -> Dictionary[Vector3i, float]:
	var grid: Dictionary[Vector3i, float]
	for x in get_axis_range(Axis.X, area):
		for y in get_axis_range(Axis.Y, area):
			for z in get_axis_range(Axis.Z, area):
				grid[Vector3i(x, y, z)] = get_arg("value", generator_data)
	return grid
