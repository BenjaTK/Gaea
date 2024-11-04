@tool
extends "res://addons/gaea/graph/components/inputs/graph_node_parameter.gd"


func _ready() -> void:
	super()
	self.value_changed.connect(param_value_changed.emit.unbind(1))


func get_param_value() -> float:
	return self.value


func set_param_value(new_value: Variant) -> void:
	self.value = new_value
