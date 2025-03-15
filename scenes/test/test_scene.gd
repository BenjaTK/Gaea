extends Node2D


@onready var gaea_generator: GaeaGenerator = $GaeaGenerator


func _ready() -> void:
	gaea_generator.data.set_parameter(&"Fill", 1.0)
	gaea_generator.generate()
