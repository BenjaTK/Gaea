@tool
class_name GaeaNodeArgument
extends Resource

enum Type {
	FLOAT,
	INT,
	VECTOR2,
	VARIABLE_NAME
}

@export var type: Type
@export var name: String

var value: Variant


func get_arg_node() -> GaeaGraphNodeParameter:
	var scene: PackedScene = get_scene_from_type(type)
	if not is_instance_valid(scene):
		return null
	var node: GaeaGraphNodeParameter = scene.instantiate()
	node.resource = self
	return node


static func get_scene_from_type(type: Type) -> PackedScene:
	match type:
		Type.FLOAT, Type.INT:
			return preload("res://addons/gaea/graph/components/inputs/number_parameter.tscn")
		Type.VECTOR2:
			return preload("res://addons/gaea/graph/components/inputs/vector2_parameter.tscn")
		Type.VARIABLE_NAME:
			return preload("res://addons/gaea/graph/components/inputs/variable_name_parameter.tscn")
	return null
