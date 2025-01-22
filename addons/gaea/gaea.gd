@tool
extends EditorPlugin


const BottomPanel = preload("res://addons/gaea/editor/panel.tscn")

var _panel: Control
var _panel_button: Button
var _editor_selection: EditorSelection


func _enter_tree() -> void:
	_editor_selection = get_editor_interface().get_selection()
	_editor_selection.selection_changed.connect(_on_selection_changed)

	_panel = BottomPanel.instantiate()
	_panel_button = add_control_to_bottom_panel(_panel, "Gaea")
	_panel_button.hide()


func _exit_tree() -> void:
	_panel.unpopulate()
	remove_control_from_bottom_panel(_panel)


func _on_selection_changed() -> void:
	var _selected: Array[Node] = _editor_selection.get_selected_nodes()

	if _selected.size() == 1 and _selected.front() is GaeaGenerator:
		_panel_button.show()
		_panel_button.set_pressed(true)
		_panel.populate(_selected.front())
	else:
		if is_instance_valid(_panel.get_selected_generator()):
			_panel_button.hide()
			_panel_button.set_pressed(false)
			_panel.unpopulate()
