@tool
class_name GaeaGraphNode
extends GraphNode


signal save_requested
signal connections_updated

@export var resource: GaeaNodeResource
var generator: GaeaGenerator

enum SlotTypes {
	VALUE_DATA, MAP_DATA, TILE_INFO, VECTOR2, NUMBER
}

var connections: Array[Dictionary]


func _ready() -> void:
	initialize()


func initialize() -> void:
	for input_slot in resource.input_slots:
		add_child(input_slot.get_node())

	for arg in resource.args:
		add_child(arg.get_arg_node())

	for output_slot in resource.output_slots:
		add_child(output_slot.get_node())

	title = resource.title
	resource.node = self


func on_added() -> void:
	pass


func get_connected_node(connection_idx: int) -> GraphNode:
	for connection in connections:
		if connection.to_port == connection_idx:
			return get_parent().get_node(NodePath(connection.from_node))
	return null


func get_connected_port(connection_idx: int) -> int:
	for connection in connections:
		if connection.to_port == connection_idx:
			return connection.from_port
	return -1


func get_arg_value(arg_name: String) -> Variant:
	for child in get_children():
		if child is GaeaGraphNodeParameter:
			if child.resource.name == arg_name:
				return child.get_param_value()
	return null


func set_arg_value(arg_name: String, value: Variant) -> void:
	for child in get_children():
		if child is GaeaGraphNodeParameter:
			if child.resource.name == arg_name:
				child.set_param_value(value)
				return


func _on_param_value_changed(value: Variant, node: GaeaGraphNodeParameter, param_name: String) -> void:
	pass


func on_removed() -> void:
	pass


func request_save() -> void:
	save_requested.emit()


func notify_connections_updated() -> void:
	connections_updated.emit()


func get_save_data() -> Dictionary:
	for arg in resource.args:
		resource.data[arg.name.to_lower()] = get_arg_value(arg.name)

	var dictionary: Dictionary = {
		"position": position_offset,
		"size": size
	}
	return dictionary


func load_save_data(data: Dictionary) -> void:
	size = data.size
	position_offset = data.position

	for child in get_children():
		if child is GaeaGraphNodeParameter:
			if resource.data.has(child.resource.name):
				child.set_param_value(resource.data[child.resource.name])


func get_color_from_type(type: SlotTypes) -> Color:
	match type:
		SlotTypes.VALUE_DATA:
			return Color("9c999e")
		SlotTypes.MAP_DATA:
			return Color("45ffa2")
		SlotTypes.TILE_INFO:
			return Color("ff4545")
		SlotTypes.VECTOR2:
			return Color("a579ff")
		SlotTypes.NUMBER:
			return Color.LIGHT_GRAY
	return Color.WHITE
