@tool
@icon("../../assets/layer.svg")
class_name GaeaLayer
extends Resource


@export var enabled: bool = true:
	set(new_value):
		if enabled != new_value:
			enabled = new_value
			emit_changed()
@export var type: GaeaValue.WireableType = GaeaValue.WireableType.MAP:
	set(new_value):
		if type != new_value:
			type = new_value
			emit_changed()
