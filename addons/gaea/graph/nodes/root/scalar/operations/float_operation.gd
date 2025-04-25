@tool
class_name GaeaNodeFloatOp
extends GaeaNodeNumOp
## A [float] operator.



func _get_title() -> String:
	return "FloatOp"


func _get_output_port_type(output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.FLOAT
