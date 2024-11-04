@tool
class_name GaeaData
extends Resource


@export_storage var connections: Array[Dictionary]
@export_storage var nodes: Array[PackedScene]
@export_storage var node_data: Array[Dictionary]
@export_storage var variables: Dictionary


func _init() -> void:
	notify_property_list_changed()



func _get_property_list() -> Array[Dictionary]:
	var list: Array[Dictionary]
	for variable in variables.values():
		list.append({
			"name": variable.name,
			"type": variable.type,
			"hint": variable.hint,
			"hint_string": variable.hint_string,
		})

	return list


func _set(property: StringName, value: Variant) -> bool:
	for variable in variables.values():
		if variable.name == property:
			variable.value = value
			return true
	return false


func _get(property: StringName) -> Variant:
	for variable in variables.values():
		if variable.name == property:
			return variable.value
	return
