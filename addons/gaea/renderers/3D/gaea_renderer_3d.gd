class_name GaeaRenderer3D
extends GaeaRenderer

## Emitted when anything is rendered, be it a chunk or the full grid.
signal area_rendered(area: AABB)
## Emitted when a chunk is rendered.
signal chunk_rendered(chunk_position: Vector3i)


## Draws the [param area]. Override this function
## to make custom [GaeaRenderer]s.
func _draw_area(area: AABB) -> void:
	push_warning("_draw_area at %s not overriden" % name)


## Draws the chunk at [param chunk_position].
func _draw_chunk(chunk_position: Vector3i) -> void:
	_draw_area(AABB(chunk_position * generator.chunk_size, generator.chunk_size))
	chunk_rendered.emit(chunk_position)


## Draws the whole grid.
func _draw() -> void:
	_draw_area(generator.grid.get_area())
	grid_rendered.emit()


func _connect_signals() -> void:
	super()

	if generator.has_signal("chunk_updated"):
		generator.chunk_updated.connect(_draw_chunk)
