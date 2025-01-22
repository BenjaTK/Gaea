@tool
extends GaeaGraphNode


func get_data(idx: int) -> Dictionary:
	var new_map: Dictionary
	var map_one: Dictionary = get_connected_input_node(0).get_data(get_from_port(0))
	var map_two: Dictionary = get_connected_input_node(1).get_data(get_from_port(1))
	for cell in map_two:
		if map_one.get_or_add(cell, null) == null:
			new_map[cell] = map_two[cell]
		else:
			new_map[cell] = map_one[cell]

	return new_map
