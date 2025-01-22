@tool
class_name TilemapGaeaRenderer
extends GaeaRenderer


@export var tilemap: TileMapLayer


func render(data: Dictionary) -> void:
	tilemap.clear()

	for cell in data.keys():
		var value = data[cell]
		if value is TilemapMaterial:
			tilemap.set_cell(Vector2i(cell.x, cell.y), value.source_id, value.atlas_coord, value.alternative_tile)
