@tool
extends PopupMenu


enum Action { ADD, DELETE, RENAME, ENABLE_TINT, TINT }

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
		add_check_item("Enable Tint Color", Action.ENABLE_TINT)
		add_item("Set Tint Color", Action.TINT)

		set_item_checked(get_item_index(Action.ENABLE_TINT), selected.front().tint_color_enabled)



func _on_id_pressed(id: int) -> void:
	var idx: int = get_item_index(id)
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

		Action.TINT:
			var selected: Array = graph_edit.get_selected()
			var node: GraphElement = selected.front()
			if node is GraphFrame:
				var popup: PopupPanel = PopupPanel.new()
				popup.position = owner.get_global_mouse_position()

				var vbox_container: VBoxContainer = VBoxContainer.new()

				var color_picker: ColorPicker = ColorPicker.new()
				color_picker.color_changed.connect(node.set_tint_color)
				color_picker.color = node.tint_color

				var ok_button: Button = Button.new()
				ok_button.text = "OK"
				ok_button.pressed.connect(popup.queue_free)

				vbox_container.add_child(color_picker)
				vbox_container.add_child(ok_button)

				popup.add_child(vbox_container)

				owner.add_child(popup)
				popup.popup()

				color_picker.grab_click_focus()
				color_picker.grab_focus()
		Action.ENABLE_TINT:
			set_item_checked(idx, not is_item_checked(idx))
			var selected: Array = graph_edit.get_selected()
			var node: GraphElement = selected.front()
			if node is GraphFrame:
				node.set_tint_color_enabled(is_item_checked(idx))
