@tool
@icon("../../assets/renderer.svg")
class_name GaeaRenderer
extends Node


@export var generator: GaeaGenerator :
	set(value):
		if is_instance_valid(generator):
			if generator.generation_finished.is_connected(render):
				generator.generation_finished.disconnect(render)
			if generator.area_erased.is_connected(_on_area_erased):
				generator.area_erased.disconnect(_on_area_erased)
			if generator.reset_requested.is_connected(reset):
				generator.reset_requested.disconnect(reset)
		generator = value
		_connect_signals()



func _ready() -> void:
	_connect_signals()


func _connect_signals() -> void:
	if not is_instance_valid(generator):
		return

	if not generator.generation_finished.is_connected(render):
		generator.generation_finished.connect(render)
	if not generator.area_erased.is_connected(_on_area_erased):
		generator.area_erased.connect(_on_area_erased)
	if not generator.reset_requested.is_connected(reset):
		generator.reset_requested.connect(reset)


func render(grid: GaeaGrid) -> void:
	pass


func _on_area_erased(aabb: AABB) -> void:
	pass


func reset() -> void:
	pass
