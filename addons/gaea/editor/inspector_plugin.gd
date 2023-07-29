extends EditorInspectorPlugin


func _can_handle(object: Object) -> bool:
	return object is GaeaGenerator


func _parse_begin(object: Object) -> void:
	if object is GaeaGenerator:
		var generateButton := GenerateButton.new()
		add_custom_control(generateButton)
