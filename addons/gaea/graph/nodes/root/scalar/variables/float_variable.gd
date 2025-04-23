@tool
class_name GaeaNodeFloatVariable
extends GaeaNodeVariable


func _get_variant_type() -> int:
	return TYPE_FLOAT


func _get_title() -> String:
	return "FloatVariable"


func _get_description() -> String:
	return "[code]float[/bg][/c] variable editable in the inspector."
