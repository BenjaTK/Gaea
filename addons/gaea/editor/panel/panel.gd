@tool
class_name GaeaPanel
extends Control


@export var main_editor: GaeaMainEditor
@export var graph_edit: GaeaGraphEdit
@export var file_list: GaeaFileList

var plugin: GaeaEditorPlugin

static func instantiate() -> Node:
	return load("uid://dngytsjlmkfg7").instantiate()


func _ready() -> void:
	if is_part_of_edited_scene():
		return
