@tool
class_name GaeaNodeVector3Variable
extends GaeaNodeVariable
## [Vector3] variable editable in the inspector.


func _get_variant_type() -> int:
	return TYPE_VECTOR3


func _get_title() -> String:
	return "Vector3Variable"


func _get_description() -> String:
	return "[code]Vector3[/bg][/c] variable editable in the inspector."
