@tool
extends "res://addons/gaea/graph/components/inputs/graph_node_parameter.gd"


func get_param_value() -> float:
	return self.value


func set_param_value(new_value: Variant) -> void:
	self.value = new_value
