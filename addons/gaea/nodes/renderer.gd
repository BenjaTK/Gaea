@tool
class_name GaeaRenderer
extends Node


@export var tilemap: TileMapLayer


func render(data: Dictionary) -> void:
	tilemap.clear()
	for cell in data.keys():
		var value = data[cell]
		if value is TilemapTileInfo:
			tilemap.set_cell(cell, value.source_id, value.atlas_coord, value.alternative_tile)
