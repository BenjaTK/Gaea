@tool
class_name GaeaNodeArgument
extends Resource

enum Type {
	FLOAT,
	INT,
	VECTOR2,
	VARIABLE_NAME, ## Used for VariableNodes.
	RANGE, ## Dictionary holding 2 keys: min and max.
	BITMASK, ## Int representing a bitmask.
	CATEGORY, ## For visual separation, doesn't get saved.
	BITMASK_EXCLUSIVE, ## Same as bitmask but only one bit can be active at once.
	FLAGS, ## Same interface as bitmask, but returns an Array of flags.
	BOOLEAN
}

@export var type: Type :
	set(value):
		type = value
		notify_property_list_changed()
@export var name: StringName
@export_storage var default_value: Variant
@export var hint: Dictionary[String, Variant]

var value: Variant


func get_arg_node() -> GaeaGraphNodeParameter:
	var scene: PackedScene = get_scene_from_type(type)
	if not is_instance_valid(scene):
		return null

	var node: GaeaGraphNodeParameter = scene.instantiate()
	node.resource = self

	return node


func get_arg_name() -> StringName:
	return name


static func get_scene_from_type(type: Type) -> PackedScene:
	match type:
		Type.FLOAT, Type.INT:
			return preload("res://addons/gaea/graph/components/inputs/number_parameter.tscn")
		Type.VECTOR2:
			return preload("res://addons/gaea/graph/components/inputs/vector2_parameter.tscn")
		Type.VARIABLE_NAME:
			return preload("res://addons/gaea/graph/components/inputs/variable_name_parameter.tscn")
		Type.RANGE:
			return preload("res://addons/gaea/graph/components/inputs/range_parameter.tscn")
		Type.BITMASK, Type.BITMASK_EXCLUSIVE, Type.FLAGS:
			return preload("res://addons/gaea/graph/components/inputs/bitmask_parameter.tscn")
		Type.CATEGORY:
			return preload("res://addons/gaea/graph/components/inputs/category.tscn")
		Type.BOOLEAN:
			return preload("res://addons/gaea/graph/components/inputs/boolean_parameter.tscn")
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
			Type.RANGE:
				property.type = TYPE_DICTIONARY
				property.usage = PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE
			Type.BITMASK, Type.BITMASK_EXCLUSIVE:
				property.type = TYPE_INT
				property.usage = PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE
				property.hint = PROPERTY_HINT_LAYERS_2D_PHYSICS
			Type.BOOLEAN:
				property.type = TYPE_BOOL
				property.usage = PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE
			Type.FLAGS:
				property.type = TYPE_ARRAY
				property.hint = PROPERTY_HINT_TYPE_STRING
				property.usage = PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE
				property.hint_string = "%d:" % [TYPE_INT]

	if property.name == "hint" and type == Type.CATEGORY:
		property.usage = PROPERTY_USAGE_NONE
