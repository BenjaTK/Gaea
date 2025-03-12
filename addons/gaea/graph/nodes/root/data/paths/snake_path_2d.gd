@tool
extends GaeaNodeResource


const LEFT_FLAG = 1 << 0
const RIGHT_FLAG = 1 << 1
const DOWN_FLAG = 1 << 2
const UP_FLAG = 1 << 3

func get_data(output_port: int, area: AABB, generator_data: GaeaData) -> Dictionary:
	var move_left_chance: float = get_arg("move_left_chance")
	var move_right_chance: float = get_arg("move_right_chance")
	var move_down_chance: float = get_arg("move_down_chance")

	var path: Dictionary
	var grid: Dictionary = {}
	var starting_cell: Vector2i = Vector2i(randi_range(0, area.size.x - 1), 0)
	var last_cell: Vector2i = starting_cell
	var current_cell: Vector2i = starting_cell

	while true:
		path[current_cell] = LEFT_FLAG | RIGHT_FLAG
		if path.get(last_cell, 0) & DOWN_FLAG:
			path[current_cell] |= UP_FLAG

		var direction: Vector2i
		while path.has(current_cell + direction):
			if randf() < move_left_chance:
				direction = Vector2i.LEFT
			elif randf() < move_right_chance:
				direction = Vector2i.RIGHT
			else:
				direction = Vector2i.DOWN

		if (current_cell + direction).x < 0 or (current_cell + direction).x >= area.size.x:
			direction = Vector2i.DOWN

		if direction == Vector2i.DOWN and current_cell.y == area.size.y:
			break

		if direction == Vector2i.DOWN:
			path[current_cell] |= DOWN_FLAG

		last_cell = current_cell
		current_cell += direction

	for x in get_axis_range(Axis.X, area):
		for y in get_axis_range(Axis.Y, area):
			grid[Vector3i(x, y, 0)] = path.get(Vector2i(x, y), 0)

	return grid
