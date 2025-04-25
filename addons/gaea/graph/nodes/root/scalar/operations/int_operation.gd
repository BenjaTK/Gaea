@tool
class_name GaeaNodeIntOp
extends GaeaNodeNumOp
## [int] operation.



func _get_title() -> String:
	return "IntOp"


func _get_output_port_type(output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.INT


func _get_operation_definitions() -> Dictionary[Operation, Definition]:
	var definitions := super()
	definitions.erase(Operation.Snapped)
	definitions.erase(Operation.Ceil)
	definitions.erase(Operation.Floor)
	definitions.erase(Operation.Round)
	definitions.erase(Operation.Smoothstep)
	definitions.erase(Operation.Remap)
	return definitions
