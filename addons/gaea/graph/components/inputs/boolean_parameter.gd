@tool
extends GaeaGraphNodeParameter


@onready var check_box: CheckBox = $CheckBox


func _ready() -> void:
	super()

	check_box.toggled.connect(param_value_changed.emit)


func get_param_value() -> bool:
	if super() != null:
		return super()
	return check_box.button_pressed


func set_param_value(new_value: Variant) -> void:
	if new_value == null:
		new_value = false
	check_box.set_pressed_no_signal(new_value)
