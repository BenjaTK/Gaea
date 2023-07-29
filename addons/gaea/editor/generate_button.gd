class_name GenerateButton extends EditorProperty


var button := Button.new()


func _init() -> void:
	anchors_preset = PRESET_HCENTER_WIDE
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	button.text = "Regenerate"
	button.icon = preload("res://addons/gaea/editor/reload.svg")
	button.custom_minimum_size.x = 128
	button.pressed.connect(_on_pressed)

	add_child(button)
	add_focusable(button)


func _on_pressed() -> void:
	var object = get_edited_object()
	if object.has_method("generate"):
		object.call("generate")

