@tool
extends GaeaNodeResource


func get_data(output_port: int, area: AABB, generator_data: GaeaData) -> Dictionary:
	var vector = get_arg("vector", generator_data)
	match output_port:
		0:
			return {"value": vector.x}
		1:
			return {"value": vector.y}
		2:
			return {"value": vector.z}
	return {}
