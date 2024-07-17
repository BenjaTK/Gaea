class_name GaeaRenderer2D
extends GaeaRenderer

## Emitted when anything is rendered, be it a chunk or the full grid.
signal area_rendered(area: Rect2i)
## Emitted when a chunk is rendered.
signal chunk_rendered(chunk_position: Vector2i)


## Draws the [param area]. Override this function
## to make custom [GaeaRenderer]s.
func _draw_area(area: Rect2i) -> void:
	push_warning("_draw_area at %s not overriden" % name)


## Draws the chunk at [param chunk_position].
func _draw_chunk(chunk_position: Vector2i) -> void:
	_draw_area(Rect2i(chunk_position * generator.chunk_size, generator.chunk_size))
	chunk_rendered.emit(chunk_position)


## Draws the whole grid.
func _draw() -> void:
	_draw_area(generator.grid.get_area())
	grid_rendered.emit()


func _connect_signals() -> void:
	super()

	if generator.has_signal("chunk_updated"):
		generator.chunk_updated.connect(_draw_chunk)
