@tool
@icon("../../assets/layer.svg")
class_name GaeaLayer
extends Resource


## Whether this layer will output anything or be [code]null[/code].
@export var enabled: bool = true:
	set(new_value):
		if enabled != new_value:
			enabled = new_value
			emit_changed()
## The type of the value this layer will hold. [GaeaRenderer]s care only about
## [GaeaValue.Map] layers, but [GaeaResult] can hold any type of values.[br]
## Only wireable types (see [method GaeaValue.is_wireable]).
@export var type: GaeaValue.Type = GaeaValue.Type.MAP:
	set(new_value):
		if type != new_value and GaeaValue.is_wireable(new_value):
			type = new_value
			emit_changed()


func _validate_property(property: Dictionary) -> void:
	if property.get("name") != "type":
		return

	var list: Array[String] = []
	var type_value: GaeaValue.Type = GaeaValue.Type.NULL
	for type_name: String in GaeaValue.Type:
		type_value = GaeaValue.Type.get(type_name)
		if GaeaValue.is_wireable(type_value):
			list.append(":".join([type_name.capitalize(), type_value]))
	property.set("hint_string", ",".join(list))
