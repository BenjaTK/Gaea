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
## [GaeaValue.Map] layers, but [GaeaResult] can hold any type of values.
@export var type: GaeaValue.WireableType = GaeaValue.WireableType.MAP:
	set(new_value):
		if type != new_value:
			type = new_value
			emit_changed()
