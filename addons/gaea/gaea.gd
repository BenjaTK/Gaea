@tool
extends EditorPlugin


var export_plugin: EditorExportPlugin


func _enter_tree() -> void:
	export_plugin = preload("uid://wjo6ua20l6lb").new()
	add_export_plugin(export_plugin)


func _enable_plugin() -> void:
	if Engine.is_editor_hint():
		EditorInterface.set_plugin_enabled("gaea/editor", true)
		EditorInterface.set_plugin_enabled("gaea/runtime", true)


func _exit_tree() -> void:
	if is_instance_valid(export_plugin):
		remove_export_plugin(export_plugin)


func _disable_plugin() -> void:
	if Engine.is_editor_hint():
		EditorInterface.set_plugin_enabled("gaea/editor", false)
		EditorInterface.set_plugin_enabled("gaea/runtime", false)
