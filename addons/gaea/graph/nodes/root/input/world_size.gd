@tool
extends GaeaNodeResource
class_name GaeaNodeInput
## Returns different input variables.


enum Inputs {
	WORLD_SIZE,
	AREA_SIZE,
	AREA_POSITION,
	AREA_END
}


func _get_enums_count() -> int:
	return 1


func _get_enum_options(_enum_idx: int) -> Dictionary:
	return Inputs


func _get_output_ports_list() -> Array[StringName]:
	return [&"value"]


func _get_overridden_output_port_idx(_output_name: StringName) -> int:
	return 0


func _get_data(output_port: StringName, area: AABB, generator_data: GaeaData) -> Vector3:
	_log_data(output_port, generator_data)

	if not is_instance_valid(generator_data.generator):
		return Vector3.ZERO
	return Vector3(generator_data.generator.world_size)
