@tool
extends "res://addons/gaea/graph/components/inputs/graph_node_parameter.gd"


func _ready() -> void:
	input_type = GaeaGraphNode.SlotTypes.NUMBER
	super()
	self.value_changed.connect(param_value_changed.emit.unbind(1))


func get_param_value() -> float:
	if super() != null:
		return super()
	return self.value


func set_param_value(new_value: Variant) -> void:
	self.value = new_value


func disable() -> void:
	self.editable = false


func enable() -> void:
	self.editable = true
