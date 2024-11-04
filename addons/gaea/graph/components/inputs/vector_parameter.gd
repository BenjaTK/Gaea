@tool
extends "res://addons/gaea/graph/components/inputs/graph_node_parameter.gd"


@onready var _x_spin_box: SpinBox = $XSpinBox
@onready var _y_spin_box: SpinBox = $YSpinBox


func _ready() -> void:
	super()
	_x_spin_box.value_changed.connect(param_value_changed.emit.unbind(1))
	_y_spin_box.value_changed.connect(param_value_changed.emit.unbind(1))


func get_param_value() -> Vector2:
	if super() != null:
		return super()
	return Vector2(_x_spin_box.value, _y_spin_box.value)


func set_param_value(new_value: Variant) -> void:
	if new_value is not Vector2:
		return
	_x_spin_box.value = new_value.x
	_y_spin_box.value = new_value.y
