@tool
extends GaeaGraphNodeArgumentEditor
class_name GaeaParameterNameArgumentEditor


@onready var line_edit: LineEdit = $LineEdit


func _configure() -> void:
	if is_part_of_edited_scene():
		return
	await super()

	line_edit.text_changed.connect(argument_value_changed.emit)

func get_arg_value() -> String:
	if super() != null:
		return super()
	return line_edit.text


func set_arg_value(new_value: Variant) -> void:
	if typeof(new_value) not in [TYPE_STRING, TYPE_STRING_NAME]:
		return
	line_edit.text = new_value
