@tool
extends GaeaGraphNode


var type: Variant.Type
var hint: PropertyHint
var hint_string: String

var previous_name: String
var _is_invalid_name: bool = false


func _on_added() -> void:
	super()

	custom_minimum_size.x = 192.0

	if resource is not GaeaNodeParameter:
		return

	var _loading_loop_limit = 60
	while not _finished_loading and _loading_loop_limit > 0:
		await get_tree().process_frame
		_loading_loop_limit -= 1
	if not _finished_loading:
		push_error("Something went wrong during loading of the variable node '%s'" % resource.get_title())

	previous_name = get_arg_value(&"name")

	if generator.data.parameters.has(get_arg_value(&"name")):
		return

	generator.data.parameters[get_arg_value(&"name")] = {
		"name": get_arg_value(&"name"),
		"type": resource.type,
		"hint": resource.hint,
		"hint_string": resource.hint_string,
		"value": _get_default_value(resource.type),
		"usage": PROPERTY_USAGE_EDITOR
	}

	generator.data.notify_property_list_changed()


func _on_removed() -> void:
	generator.data.parameters.erase(get_arg_value("name"))
	generator.data.notify_property_list_changed()


func get_save_data() -> Dictionary:
	var save_data := super()
	if _is_invalid_name:
		if previous_name.is_empty():
			previous_name = resource.get_argument_default_value(&"name")
		save_data.get(&"arguments").set(&"name", previous_name)
	return save_data


func _on_argument_value_changed(value: Variant, node: GaeaGraphNodeArgumentEditor, arg_name: String) -> void:
	if arg_name != "name" and value is not String:
		return

	if value.is_empty():
		node.line_edit.text = previous_name
		return

	node.line_edit.remove_theme_color_override("font_color")
	_is_invalid_name = false
	if generator.data.parameters.has(value) and value != previous_name:
		_is_invalid_name = true
		node.line_edit.add_theme_color_override("font_color", Color.RED)
		return

	if value == previous_name:
		return

	generator.data.parameters[value] = generator.data.parameters.get(previous_name)
	generator.data.parameters.erase(previous_name)
	generator.data.parameters[value].name = value

	previous_name = value

	generator.data.notify_property_list_changed()
	save_requested.emit.call_deferred()



func _get_default_value(for_type: Variant.Type) -> Variant:
	match for_type:
		TYPE_FLOAT, TYPE_INT:
			return 0
		TYPE_VECTOR2:
			return Vector2(0, 0)
		TYPE_VECTOR2I:
			return Vector2i(0, 0)
		TYPE_VECTOR3:
			return Vector3(0, 0, 0)
		TYPE_VECTOR3I:
			return Vector3i(0, 0, 0)
	return null
