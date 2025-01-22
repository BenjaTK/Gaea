@tool
extends Tree


signal node_selected_for_creation(resource: GaeaNodeResource)

const NODES_FOLDER_PATH: String = "res://addons/gaea/graph/nodes/root/"


func _ready() -> void:
	var root: TreeItem = create_item()
	hide_root = true
	_populate_tree_with_files(NODES_FOLDER_PATH, root)
	root.set_collapsed_recursive(true)
	root.set_collapsed(false)


func _populate_tree_with_files(folder_path: String, parent_item: TreeItem) -> void:
	var dir := DirAccess.open(folder_path)
	if dir == null:
		push_error(error_string(DirAccess.get_open_error()))
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and not file_name.ends_with(".tres"):
			file_name = dir.get_next()
			continue

		var tree_item: TreeItem = create_item(parent_item)
		tree_item.set_text(0, file_name.get_basename().capitalize())

		var file_path = folder_path + file_name
		if dir.current_is_dir():
			_populate_tree_with_files(file_path + "/", tree_item)

		if file_name.ends_with(".tres"):
			tree_item.set_metadata(0, load(file_path))
			print(file_name)

		file_name = dir.get_next()


func _on_item_activated() -> void:
	var item: TreeItem = get_selected()
	if item.get_metadata(0) is GaeaNodeResource:
		node_selected_for_creation.emit(item.get_metadata(0).duplicate())


func _on_create_button_pressed() -> void:
	_on_item_activated()
