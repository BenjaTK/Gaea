@tool
extends "res://addons/gaea/graph/components/inputs/graph_node_parameter.gd"


@onready var spin_box: SpinBox = $SpinBox


func _ready() -> void:
	super()
	if not is_instance_valid(resource):
		return

	spin_box.value_changed.connect(param_value_changed.emit)

	if resource.type == GaeaNodeArgument.Type.INT:
		spin_box.step = 1

	spin_box.min_value = resource.hint.get("min", 0.0)
	spin_box.allow_lesser = not resource.hint.has("min")

	spin_box.max_value = resource.hint.get("max", 1.0)
	spin_box.allow_greater = not resource.hint.has("max")


func get_param_value() -> float:
	if super() != null:
		return super()
	return spin_box.value


func set_param_value(new_value: Variant) -> void:
	if typeof(new_value) not in [TYPE_FLOAT, TYPE_INT]:
		return
	spin_box.value = new_value
