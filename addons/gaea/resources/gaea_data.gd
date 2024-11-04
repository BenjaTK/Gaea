@tool
class_name GaeaData
extends Resource


@export_storage var connections: Array[Dictionary]
@export_storage var nodes: Array[PackedScene]
@export_storage var node_data: Array[Dictionary]
@export_storage var parameters: Dictionary
@export_storage var scroll_offset: Vector2


func _init() -> void:
	notify_property_list_changed()



func _get_property_list() -> Array[Dictionary]:
	var list: Array[Dictionary]
	list.append({
		"name": "Parameters",
		"type": TYPE_NIL,
		"usage": PROPERTY_USAGE_GROUP,
	})
	for variable in parameters.values():
		if variable == null:
			parameters.erase(parameters.find_key(variable))
			continue

		list.append(variable)

	return list


func _set(property: StringName, value: Variant) -> bool:
	for variable in parameters.values():
		if variable == null:
			continue

		if variable.name == property:
			variable.value = value
			return true
	return false


func _get(property: StringName) -> Variant:
	for variable in parameters.values():
		if variable == null:
			continue

		if variable.name == property:
			return variable.value
	return
