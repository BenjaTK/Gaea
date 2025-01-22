@tool
class_name GaeaNodeResource
extends Resource


@export var input_slots: Array[GaeaNodeSlot]
@export var args: Array[GaeaNodeArgument]
@export var output_slots: Array[GaeaNodeSlot]
@export var title: String = "Node"
@export_multiline var description: String = ""
@export var is_output: bool = false

@export_storage var data: Dictionary
var connections: Array[Dictionary]
var node: GraphNode

enum Axis {X, Y, Z}


func get_data(output_port: int, area: AABB, generator_data: GaeaData) -> Dictionary:
	return {}


func execute(area: AABB, generator_data: GaeaData, generator: GaeaGenerator) -> void:
	pass


func get_arg(name: String, generator_data: GaeaData = null) -> Variant:
	var arg_connection_idx: int = 0
	for i in args.size():
		if args[i].name == name:
			arg_connection_idx = i + input_slots.size()
			break

	if arg_connection_idx != -1 and is_instance_valid(generator_data):
		if get_connected_resource_idx(arg_connection_idx) != -1:
			return generator_data.resources[get_connected_resource_idx(arg_connection_idx)].get_data(
				get_connected_port_to(arg_connection_idx),
				AABB(),
				generator_data
			).value

	return data.get(name)


func get_connected_resource_idx(at: int) -> int:
	for connection in connections:
		if connection.to_port == at:
			return connection.from_node
	return -1


func get_connected_port_to(to: int) -> int:
	for connection in connections:
		if connection.to_port == to:
			return connection.from_port
	return -1


static func get_scene() -> PackedScene:
	return preload("res://addons/gaea/graph/nodes/node.tscn")


func get_axis_range(axis: Axis, area: AABB) -> Array:
	match axis:
		Axis.X: return range(area.position.x, area.size.x)
		Axis.Y: return range(area.position.y, area.size.y)
		Axis.Z: return range(area.position.z, area.size.z)
	return []
