@tool
class_name GaeaNodeFloatConstant
extends GaeaNodeConstant
## [float] constant.


func _get_output_port_type(output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.FLOAT


func _get_title() -> String:
	return "FloatConstant"


func _get_description() -> String:
	return "[code]float[/bg][/c] constant."
