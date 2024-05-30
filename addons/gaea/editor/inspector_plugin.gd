extends EditorInspectorPlugin


func _can_handle(object: Object) -> bool:
	return object is GaeaGenerator or object is Modifier2D or object is Modifier3D or object is NoiseGeneratorData


func _parse_begin(object: Object) -> void:
	if object is GaeaGenerator:
		var generator_buttons := preload("./generator_buttons.gd").new()
		add_custom_control(generator_buttons)

	if (object is Modifier and object.get("noise") and object.get("threshold")) or\
		(object is NoiseGeneratorData and object.settings):
		var texture_rect := preload("./threshold_visualizer.gd").new()
		texture_rect.object = object

		add_custom_control(texture_rect)

		texture_rect.update()
		if object.get("noise"):
			object.get("noise").changed.connect(texture_rect.update)
		object.changed.connect(texture_rect.update)
