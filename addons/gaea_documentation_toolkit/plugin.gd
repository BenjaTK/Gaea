@tool
extends EditorPlugin

const DocumentationToolkit = preload("uid://bxanwt5o3b0ng")

var _dock: EditorDock


func _enter_tree() -> void:
	_dock = EditorDock.new()
	_dock.available_layouts = EditorDock.DOCK_LAYOUT_FLOATING | EditorDock.DOCK_LAYOUT_HORIZONTAL
	_dock.title = "Gaea Documentation Toolkit"
	_dock.default_slot = EditorDock.DOCK_SLOT_BOTTOM

	_dock.add_child(DocumentationToolkit.instantiate())
	add_dock(_dock)


func _exit_tree() -> void:
	remove_dock(_dock)
	_dock.queue_free()
	_dock = null
