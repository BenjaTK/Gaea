@tool
class_name GaeaNodeBoolVariable
extends GaeaNodeVariable
## [bool] variable editable in the inspector.


func _get_variant_type() -> int:
	return TYPE_BOOL


func _get_title() -> String:
	return "BoolVariable"


func _get_description() -> String:
	return "[code]bool[/bg][/c] variable editable in the inspector."
