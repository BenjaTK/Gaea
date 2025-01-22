@tool
extends GaeaGraphNode


func initialize() -> void:
	if not is_instance_valid(resource):
		return

	title = resource.title
	resource.node = self
	for layer in generator.data.layers.size():
		_add_layer_slot(layer)


func _add_layer_slot(idx: int) -> void:
	var resource: GaeaNodeSlot = GaeaNodeSlot.new()
	resource.left_enabled = true
	resource.left_label = "Layer %s" % idx
	resource.left_type = GaeaGraphNode.SlotTypes.MAP_DATA
	resource.right_enabled = false
	add_child(resource.get_node())


func update_slots() -> void:
	var layer_count: int = generator.data.layers.size()
	if layer_count < get_child_count():
		for i in range(get_child_count(), layer_count, -1):
			var child: Control = get_child(i - 1)
			child.queue_free()
			await child.tree_exited
			size.y = get_combined_minimum_size().y
	elif layer_count > get_child_count():
		for i in range(get_child_count(), layer_count):
			_add_layer_slot(i)
