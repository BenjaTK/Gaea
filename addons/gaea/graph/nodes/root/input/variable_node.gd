@tool
extends GaeaNodeResource
class_name GaeaVariableNodeResource


@export var type: Variant.Type
@export var hint: PropertyHint
@export var hint_string: String
@export var output_type: GaeaGraphNode.SlotTypes


func get_data(output_port: int, area: AABB, generator_data: GaeaData) -> Dictionary:
	return generator_data.parameters.get(get_arg("name", null))


static func get_scene() -> PackedScene:
	return preload("res://addons/gaea/graph/nodes/variable_node.tscn")
