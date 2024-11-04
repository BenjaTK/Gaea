@tool
extends Control

signal param_value_changed


func _ready() -> void:
	if owner is GaeaGraphNode:
		param_value_changed.connect(owner.request_save)


func get_param_value() -> Variant:
	return null


func set_param_value(new_value: Variant) -> void:
	pass
