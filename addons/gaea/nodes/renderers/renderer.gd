@tool
class_name GaeaRenderer
extends Node


@export var generator: GaeaGenerator :
	set(value):
		if is_instance_valid(generator):
			if generator.generation_finished.is_connected(render):
				generator.generation_finished.disconnect(render)
		generator = value
		_connect_signals()



func _ready() -> void:
	_connect_signals()


func _connect_signals() -> void:
	if not generator.generation_finished.is_connected(render):
		generator.generation_finished.connect(render)


func render(grid: GaeaGrid) -> void:
	pass
