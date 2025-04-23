@tool
class_name GaeaNodeVector2Variable
extends GaeaNodeVariable


func _get_variant_type() -> int:
	return TYPE_VECTOR2


func _get_title() -> String:
	return "Vector2Variable"


func _get_description() -> String:
	return "[code]Vector2[/bg][/c] variable editable in the inspector."
