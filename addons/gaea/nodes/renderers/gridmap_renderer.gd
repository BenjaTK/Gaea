@tool
class_name GridmapGaeaRenderer
extends GaeaRenderer


@export var gridmap: GridMap


func render(grid: GaeaGrid) -> void:
	gridmap.clear()

	for layer in grid.get_layers():
		for cell in layer.keys():
			var value = layer[cell]
			if value is GridmapMaterial:
				gridmap.set_cell_item(cell, value.item_idx)
