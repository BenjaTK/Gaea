extends EditorProperty

var button := Button.new()


func _init() -> void:
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	var container := HBoxContainer.new()
	container.custom_minimum_size.x = 130
	add_child(container)

	var generate_button := _add_button(container, "Generate", preload("./reload.svg"), _on_generate_pressed)
	generate_button.custom_minimum_size.x = 110

	_add_button(container, "Clear", preload("./clear.svg"), _on_clear_pressed)


func _add_button(container: Container, text: String, icon: Texture2D, onPressed: Callable) -> Button:
	var button := Button.new()

	button.text = text
	button.icon = icon

	button.pressed.connect(onPressed)

	container.add_child(button)
	add_focusable(button)

	return button


func _on_generate_pressed() -> void:
	var object = get_edited_object()
	if object.has_method("generate"):
		object.call("generate")


func _on_clear_pressed() -> void:
	var object = get_edited_object()
	if object.has_method("erase"):
		object.call("erase")
