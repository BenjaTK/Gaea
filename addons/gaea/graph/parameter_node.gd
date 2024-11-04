@tool
extends GaeaGraphNode


@export var type: Variant.Type
@export var hint: PropertyHint
@export var hint_string: String

@onready var _line_edit: LineEdit = $LineEdit

var variable_name: String


func get_data(idx: int) -> Dictionary:
	return {"value": _generator.data.parameters[variable_name].value}


func on_added() -> void:
	_line_edit.text_changed.connect(_on_line_edit_text_changed)

	variable_name = _line_edit.text
	var _suffix: int = 1
	while _generator.data.parameters.has(variable_name):
		_suffix += 1
		variable_name = "%s%s" % [_line_edit.text, _suffix]
	_line_edit.text = variable_name

	_generator.data.parameters[variable_name] = {
		"name": variable_name,
		"type": type,
		"hint": hint,
		"hint_string": hint_string,
		"value": null,
	}

	_generator.data.notify_property_list_changed()


func on_removed() -> void:
	_generator.data.parameters.erase(variable_name)
	_generator.data.notify_property_list_changed()


func _on_line_edit_text_changed(new_text: String) -> void:
	_line_edit.remove_theme_color_override("font_color")
	if _generator.data.parameters.has(new_text):
		_line_edit.add_theme_color_override("font_color", Color.RED)
		return

	_generator.data.parameters[new_text] = _generator.data.parameters.get(variable_name)
	_generator.data.parameters.erase(variable_name)
	_generator.data.parameters[new_text].name = new_text

	variable_name = new_text

	_generator.data.notify_property_list_changed()


func get_save_data() -> Dictionary:
	var dictionary: Dictionary = super()
	dictionary["variable_name"] = variable_name
	return dictionary


func load_save_data(data: Dictionary) -> void:
	super(data)
	variable_name = data["variable_name"]
	_line_edit.text = variable_name
