@tool
extends EditorPlugin

var _inspector_plugin = preload("./editor/inspector_plugin.gd")
var _update_button = preload("./editor/update_button.tscn")


func _enter_tree() -> void:
	_inspector_plugin = _inspector_plugin.new()
	add_inspector_plugin(_inspector_plugin)

	_update_button = _update_button.instantiate()
	_update_button.editor_plugin = self
	add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, _update_button)


func _exit_tree() -> void:
	remove_inspector_plugin(_inspector_plugin)
	remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR, _update_button)
