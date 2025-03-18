@tool
extends PopupMenu


enum Action { ADD, DELETE, RENAME, TINT }

@export var graph_edit: GraphEdit

signal create_node_popup_requested


func _ready() -> void:
	hide()
	id_pressed.connect(_on_id_pressed)


func populate(selected: Array) -> void:
	add_item("Add Node", Action.ADD)
	add_separator()
	add_item("Delete", Action.DELETE)
	if selected.front() is GraphFrame and selected.size() == 1:
		add_separator()
		add_item("Rename Frame", Action.RENAME)
		add_item("Set Tint Color", Action.TINT)



func _on_id_pressed(id: int) -> void:
	match id:
		Action.ADD:
			create_node_popup_requested.emit()
		Action.DELETE:
			graph_edit.delete_nodes(graph_edit.get_selected_names())

		Action.RENAME:
			var selected: Array = graph_edit.get_selected()
			var node: GraphElement = selected.front()
			if node is GraphFrame:
				var line_edit: LineEdit = LineEdit.new()
				line_edit.position = owner.get_local_mouse_position()
				line_edit.text_submitted.connect(node.set_title)
				line_edit.text_submitted.connect(line_edit.queue_free.unbind(1), CONNECT_DEFERRED)
				line_edit.focus_exited.connect(line_edit.queue_free)
				owner.add_child(line_edit)
				line_edit.grab_click_focus()
				line_edit.grab_focus()
