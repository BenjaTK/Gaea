@tool
extends GaeaNodeResource


func get_data(output_port: int, area: Rect2i, generator_data: GaeaData) -> Dictionary:
	var grid: Dictionary
	for x in get_axis_range(Axis.X, area):
		for y in get_axis_range(Axis.Y, area):
			grid[Vector2i(x, y)] = get_arg("value", generator_data)
	return grid
