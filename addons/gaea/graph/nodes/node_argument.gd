@tool
class_name GaeaNodeArgument
extends Resource

enum Type {
	FLOAT,
	INT,
	VECTOR2,
	VARIABLE_NAME
}

@export var type: Type :
	set(value):
		type = value
		notify_property_list_changed()
@export var name: String
@export_storage var default_value: Variant

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


func _validate_property(property: Dictionary) -> void:
	if property.name == "default_value":
		match type:
			Type.FLOAT:
				property.type = TYPE_FLOAT
				property.usage = PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE
			Type.INT:
				property.type = TYPE_INT
				property.usage = PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE
			Type.VECTOR2:
				property.type = TYPE_VECTOR2
				property.usage = PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE
