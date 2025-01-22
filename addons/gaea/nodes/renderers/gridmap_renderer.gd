@tool
class_name GridmapGaeaRenderer
extends GaeaRenderer


@export var gridmap: GridMap


func render(data: Dictionary) -> void:
	gridmap.clear()

	for cell in data.keys():
		var value = data[cell]
		if value is GridmapMaterial:
			gridmap.set_cell_item(cell, value.item_idx)
