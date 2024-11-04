@tool
class_name GaeaGraphNode
extends GraphNode


signal save_requested
signal connections_updated

enum SlotTypes {
	VALUE_DATA, TILE_DATA, TILE_INFO, VECTOR2, NUMBER
}

@export var is_output: bool = false

var connections: Array[Dictionary]
var _generator: GaeaGenerator : set = set_generator_reference


func _ready() -> void:
	for idx in get_child_count():
		set_slot(idx, false, -1, Color.WHITE, false, -1, Color.WHITE)


func get_color_from_type(type: SlotTypes) -> Color:
	match type:
		SlotTypes.VALUE_DATA:
			return Color("9c999e")
		SlotTypes.TILE_DATA:
			return Color("45ffa2")
		SlotTypes.TILE_INFO:
			return Color("ff4545")
		SlotTypes.VECTOR2:
			return Color("a579ff")
		SlotTypes.NUMBER:
			return Color.LIGHT_GRAY
	return Color.WHITE


#region Gaea Functions
func execute() -> void:
	return


func get_data(idx: int) -> Dictionary:
	return {}


func on_added() -> void:
	return


func on_removed() -> void:
	return


func notify_connections_updated() -> void:
	connections_updated.emit()
#endregion


#region Getters & Setters
func set_generator_reference(value: GaeaGenerator) -> void:
	_generator = value


func get_connected_input_node(connection_idx: int) -> GaeaGraphNode:
	for connection in connections:
		if connection.to_port == connection_idx:
			return get_parent().get_node(NodePath(connection.from_node))
	return null


func get_from_port(connection_idx: int) -> int:
	for connection in connections:
		if connection.to_port == connection_idx:
			return connection.from_port
	return -1
#endregion

#region Saving and Loading
func request_save() -> void:
	save_requested.emit()


func get_save_data() -> Dictionary:
	var dictionary: Dictionary = {
		"position": position_offset,
		"size": size
	}
	return dictionary


func load_save_data(data: Dictionary) -> void:
	position_offset = data.position
	size = data.size
#endregion
