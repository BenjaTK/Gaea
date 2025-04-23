@tool
class_name GaeaNodeMaterialVariable
extends GaeaNodeVariable



func _get_variant_type() -> int:
	return TYPE_OBJECT


func _get_property_hint() -> PropertyHint:
	return PROPERTY_HINT_RESOURCE_TYPE


func _get_property_hint_string() -> String:
	return "GaeaMaterial"


func _get_title() -> String:
	return "MaterialVariable"


func _get_description() -> String:
	return "GaeaMaterial variable editable in the inspector."
