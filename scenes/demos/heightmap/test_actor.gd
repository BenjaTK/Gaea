extends Node2D

@export var speed: float

func _physics_process(delta: float) -> void:
	var move: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	global_position += move * delta * speed
