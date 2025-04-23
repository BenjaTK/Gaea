@tool
class_name GaeaNodeIntVariable
extends GaeaNodeVariable
## [int] variable editable in the inspector.


func _get_variant_type() -> int:
	return TYPE_INT


func _get_title() -> String:
	return "IntVariable"


func _get_description() -> String:
	return "[code]int[/bg][/c] variable editable in the inspector."
