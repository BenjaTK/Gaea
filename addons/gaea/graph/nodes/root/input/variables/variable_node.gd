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


func get_icon() -> Texture2D:
	match type:
		TYPE_FLOAT:
			return preload("../../../../../assets/types/float.svg")
		TYPE_INT:
			return preload("../../../../../assets/types/int.svg")
		TYPE_VECTOR2:
			return preload("../../../../../assets/types/vec2.svg")
		TYPE_BOOL:
			return preload("../../../../../assets/types/bool.svg")
		TYPE_OBJECT:
			if hint_string == "GaeaMaterial": return preload("../../../../../assets/material.svg")
	return null
