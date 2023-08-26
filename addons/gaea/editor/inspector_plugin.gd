extends EditorInspectorPlugin


func _can_handle(object: Object) -> bool:
	return object is GaeaGenerator


func _parse_begin(object: Object) -> void:
	if object is GaeaGenerator:
		var generator_buttons := preload("res://addons/gaea/editor/generator_buttons.gd").new()
		add_custom_control(generator_buttons)
