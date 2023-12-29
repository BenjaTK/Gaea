@tool
class_name TilemapGaeaRenderer
extends GaeaRenderer2D
## Uses the [param tile_map] to draw the generator's [param grid].
##
## Takes [TilemapTileInfo] to determine which tile to place
## in every cell.


@export var tile_map: TileMap :
	set(value):
		tile_map = value
		update_configuration_warnings()
@export var clear_tile_map_on_draw: bool = true
## Erases the cell when an empty tile is found. Recommended: true.
@export var erase_empty_tiles: bool = true


func _draw_area(area: Rect2i) -> void:
	var terrains: Dictionary

	for x in range(area.position.x, area.end.x + 1):
		for y in range(area.position.y, area.end.y + 1):
			var tile_position := Vector2i(x, y)
			var has_cell_in_position: bool = false
			for layer in range(generator.grid.get_layer_count()):
				if generator.grid.has_cell(tile_position, layer):
					has_cell_in_position = true

			if erase_empty_tiles and not has_cell_in_position:
				for l in range(tile_map.get_layers_count()):
					tile_map.erase_cell(l, Vector2i(x, y))
				continue

			for layer in range(generator.grid.get_layer_count()):
				var tile = tile_position
				var tile_info = generator.grid.get_value(tile_position, layer)

				if not (tile_info is TilemapTileInfo):
					continue

				match tile_info.type:
					TilemapTileInfo.Type.SINGLE_CELL:
						tile_map.set_cell(
							tile_info.tilemap_layer, tile, tile_info.source_id,
							tile_info.atlas_coord, tile_info.alternative_tile
						)
					TilemapTileInfo.Type.TERRAIN:
						if not terrains.has(tile_info):
							terrains[tile_info] = [tile]
						else:
							terrains[tile_info].append(tile)

	for tile_info in terrains:
		tile_map.set_cells_terrain_connect(
			tile_info.tilemap_layer, terrains[tile_info],
			tile_info.terrain_set, tile_info.terrain
		)

	area_rendered.emit()


func _draw() -> void:
	if clear_tile_map_on_draw:
		tile_map.clear()
	super._draw()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray

	warnings.append_array(super._get_configuration_warnings())

	if not is_instance_valid(tile_map):
		warnings.append("Needs a TileMap to work.")

	return warnings
