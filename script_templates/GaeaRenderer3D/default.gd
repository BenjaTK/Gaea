@tool
extends GaeaRenderer3D


func _draw_area(area: AABB) -> void:
	# Write rendering code here.

	area_rendered.emit()
