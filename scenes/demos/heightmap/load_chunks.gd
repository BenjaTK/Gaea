extends Node

@export var generator: HeightmapGenerator2D
@export var load: Rect2i

func _ready() -> void:
	for x in range(load.position.x, load.size.x):
		for y in range(load.position.y, load.size.y, -1):
			generator.generate_chunk(Vector2i(x, y))
	
