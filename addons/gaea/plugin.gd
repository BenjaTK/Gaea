@tool
extends EditorPlugin


var _inspector_plugin = preload("./editor/inspector_plugin.gd")


func _enter_tree() -> void:
	_inspector_plugin = _inspector_plugin.new()
	add_inspector_plugin(_inspector_plugin)


func _exit_tree() -> void:
	remove_inspector_plugin(_inspector_plugin)
