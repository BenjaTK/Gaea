@tool
extends EditorPlugin


var inspectorPlugin = preload("res://addons/gaea/editor/inspector_plugin.gd")


func _enter_tree() -> void:
	inspectorPlugin = inspectorPlugin.new()
	add_inspector_plugin(inspectorPlugin)


func _exit_tree() -> void:
	remove_inspector_plugin(inspectorPlugin)
