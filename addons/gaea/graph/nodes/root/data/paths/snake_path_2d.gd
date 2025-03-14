@tool
extends GaeaNodeResource

const LEFT_FLAG = 1 << 0
const RIGHT_FLAG = 1 << 1
const DOWN_FLAG = 1 << 2
const UP_FLAG = 1 << 3

func get_data(output_port: int, area: AABB, generator_data: GaeaData) -> Dictionary:
	var weights: Dictionary = {
		"move_left_weight" :{ "direction":Vector2i.LEFT,  "weight":get_arg("move_left_weight")  },
		"move_right_weight":{ "direction":Vector2i.RIGHT, "weight":get_arg("move_right_weight") },
		"move_down_weight" :{ "direction":Vector2i.DOWN,  "weight":get_arg("move_down_weight")  },
	}
	var weight_sum:int = 0
	for weight in weights.values():
		weight_sum += weight.weight

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
			var rand = randi_range(1, weight_sum)
			var cur_range = 0
			for weight in weights.values():
				cur_range += weight.weight
				if rand <= cur_range:
					direction = weight.direction
					break

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
