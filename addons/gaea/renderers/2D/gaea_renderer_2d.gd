class_name GaeaRenderer2D
extends GaeaRenderer


## Draws the [param area]. Override this function
## to make custom [GaeaRenderer]s.
func _draw_area(area: Rect2i) -> void:
	push_warning("_draw_area at %s not overriden" % name)


## Draws the chunk at [param chunk_position].
func _draw_chunk(chunk_position: Vector2i) -> void:
	_draw_area(Rect2i(
			chunk_position * generator.chunk_size,
			Vector2i(generator.chunk_size, generator.chunk_size))
		)

## Draws the whole grid.
func _draw() -> void:
	_draw_area(generator.grid.get_area())


func _connect_signals() -> void:
	super()

	if generator.has_signal("chunk_updated"):
		generator.chunk_updated.connect(_draw_chunk)
