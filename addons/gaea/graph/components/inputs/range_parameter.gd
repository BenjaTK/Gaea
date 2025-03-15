@tool
extends "res://addons/gaea/graph/components/inputs/graph_node_parameter.gd"


@onready var min_slider: HSlider = $MinSlider
@onready var max_slider: HSlider = $MinSlider/MaxSlider
@onready var area_panel: Panel = $MinSlider/AreaPanel
@onready var min_spin_box: SpinBox = $HBoxContainer/MinSpinBox
@onready var max_spin_box: SpinBox = $HBoxContainer/MaxSpinBox




func _ready() -> void:
	min_slider.value_changed.connect(_on_slider_changed_value.unbind(1))
	max_slider.value_changed.connect(_on_slider_changed_value.unbind(1))
	min_spin_box.value_changed.connect(_on_spin_box_changed_value.unbind(1))
	max_spin_box.value_changed.connect(_on_spin_box_changed_value.unbind(1))
	super()


func _on_slider_changed_value() -> void:
	min_slider.set_value_no_signal(minf(min_slider.value, max_slider.value))
	max_slider.set_value_no_signal(maxf(max_slider.value, min_slider.value))
	area_panel.size.x = min_slider.size.x * clampf(minf(1.0, max_slider.value) - maxf(0.0, min_slider.value), 0.0, 1.0)
	area_panel.position.x = min_slider.size.x * clampf(min_slider.value, 0.0, 1.0)
	min_spin_box.set_value_no_signal(min_slider.value)
	max_spin_box.set_value_no_signal(max_slider.value)
	param_value_changed.emit(get_param_value())


func _on_spin_box_changed_value() -> void:
	min_spin_box.set_value_no_signal(minf(min_spin_box.value, max_spin_box.value))
	max_spin_box.set_value_no_signal(maxf(max_spin_box.value, min_spin_box.value))
	min_slider.set_value(min_spin_box.value)
	max_slider.set_value(max_spin_box.value)


func _input(event: InputEvent) -> void:
	if event is not InputEventMouseButton:
		return

	if event.is_released() and event.button_index == MOUSE_BUTTON_LEFT:
		min_slider.editable = false
		max_slider.editable = false
		min_slider.release_focus()
		max_slider.release_focus()


func _on_min_slider_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var relative_position: float = event.position.x / min_slider.size.x

		if max_slider.has_focus():
			max_slider.value = clampf(relative_position, 0.0, 1.0)

	if event is not InputEventMouseButton:
		return

	if event.button_index != MOUSE_BUTTON_LEFT:
		return

	if event.is_pressed():
		var relative_position: float = event.position.x / min_slider.size.x

		if abs(min_slider.value - relative_position) < 0.05:
			min_slider.grab_focus()
			min_slider.editable = true
		elif abs(max_slider.value - relative_position) < 0.05:
			max_slider.grab_focus()
			max_slider.editable = true

	elif event.is_released():
		min_slider.editable = false
		max_slider.editable = false
		min_slider.release_focus()
		max_slider.release_focus()


func get_param_value() -> Dictionary:
	if super() != null:
		return super()
	return {
		"max": max_slider.value,
		"min": min_slider.value
	}


func set_param_value(new_value: Variant) -> void:
	if new_value == null:
		new_value = {"max": 1.0, "min": 0.0}
	max_slider.value = new_value["max"]
	min_slider.value = new_value["min"]
