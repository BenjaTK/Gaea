@tool
extends GaeaGraphNode


@onready var open_button: Button = $OpenButton


func _on_added() -> void:
	if not is_instance_valid(resource) or is_part_of_edited_scene():
		return

	open_button.add_to_group(KEEP_IN_REBUILD_GROUP)
	open_button.pressed.connect(_open)
	super()


func _open() -> void:
	graph_edit.unpopulate()
	graph_edit.populate(resource.subgraph)
