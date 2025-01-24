@tool
class_name GridmapGaeaRenderer
extends GaeaRenderer


@export var gridmap: GridMap


func render(grid: GaeaGrid) -> void:
	gridmap.clear()

	for layer_idx in grid.get_layers_count():
		for cell in grid.get_layer(layer_idx):
			var value = grid.get_layer(layer_idx)[cell]
			if value is GridmapMaterial:
				gridmap.set_cell_item(cell, value.item_idx)
