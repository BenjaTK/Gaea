@tool
extends GaeaNodeResource


@export_enum("Vector2", "Vector3") var type: int = 0


func get_data(output_port: int, area: AABB, generator_data: GaeaData) -> Dictionary:
	if type == 0:
		return {
			"value": Vector2(
				get_arg("x", generator_data),
				get_arg("y", generator_data)
			)
		}
	elif type == 1:
		return {
			"value": Vector3(
				get_arg("x", generator_data),
				get_arg("y", generator_data),
				get_arg("z", generator_data)
			)
		}
	return {}
