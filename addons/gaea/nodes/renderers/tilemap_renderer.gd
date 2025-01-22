@tool
class_name TilemapGaeaRenderer
extends GaeaRenderer


@export var tile_map_layers: Array[TileMapLayer] = []


func render(grid: GaeaGrid) -> void:
	for tile_map_layer in tile_map_layers:
		tile_map_layer.clear()

	for layer_idx in grid.get_layers_count():
		for cell in grid.get_layer(layer_idx):
			var value = grid.get_layer(layer_idx)[cell]
			if value is TilemapMaterial:
				if tile_map_layers.size() <= layer_idx:
					continue
				tile_map_layers[layer_idx].set_cell(Vector2i(cell.x, cell.y), value.source_id, value.atlas_coord, value.alternative_tile)
