@tool
extends GaeaRenderer2D


func _draw_area(area: Rect2i) -> void:
	# Write rendering code here.

	area_rendered.emit(area)
