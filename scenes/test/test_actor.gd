extends Sprite2D


func _process(delta: float) -> void:
	var move: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	translate(move * delta * 256.0)
