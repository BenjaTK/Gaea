extends EditorExportPlugin


func _get_name() -> String:
	return "GDA_Gaea"


func _export_file(path: String, _type: String, _features: PackedStringArray) -> void:
	if path.begins_with("res://addons/gaea/editor/"):
		skip()
		return
