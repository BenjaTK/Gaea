@tool
class_name GaeaNodeGradientVariable
extends GaeaNodeVariable


func _get_variant_type() -> int:
	return TYPE_OBJECT


func _get_property_hint() -> PropertyHint:
	return PROPERTY_HINT_RESOURCE_TYPE


func _get_property_hint_string() -> String:
	return "GaeaMaterialGradient"


func _get_title() -> String:
	return "MaterialGradientVariable"


func _get_description() -> String:
	return "GaeaMaterialGradient variable editable in the inspector."
