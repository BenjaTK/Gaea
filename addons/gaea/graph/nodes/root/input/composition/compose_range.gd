@tool
extends GaeaNodeResource


func get_data(output_port: int, area: AABB, generator_data: GaeaData) -> Dictionary:
	return {
		"value": {
			"max": get_arg("max", generator_data),
			"min": get_arg("min", generator_data)
		}

	}
