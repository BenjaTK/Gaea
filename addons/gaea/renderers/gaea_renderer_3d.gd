class_name GaeaRenderer3D
extends GaeaRenderer


## Draws the [param area]. Override this function
## to make custom [GaeaRenderer]s.
func _draw_area(area: AABB) -> void:
	pass


## Draws the whole grid.
func _draw() -> void:
	_draw_area(generator.get_area_from_grid(generator.grid))
