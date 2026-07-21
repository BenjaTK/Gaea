@tool
# class_name GaeaNode...Constant
extends GaeaNodeConstant
## type constant.


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.NULL


func _get_title() -> String:
	return "TypeConstant"


func _get_description() -> String:
	return "type constant."
