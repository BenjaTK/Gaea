@tool
extends "res://addons/gaea/graph/components/inputs/graph_node_parameter.gd"


@onready var spin_box: SpinBox = $SpinBox


func _ready() -> void:
	super()
	spin_box.value_changed.connect(param_value_changed.emit)


func get_param_value() -> float:
	if super() != null:
		return super()
	return spin_box.value


func set_param_value(new_value: Variant) -> void:
	spin_box.value = new_value
