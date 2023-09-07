@tool
class_name TilemapGaeaRenderer
extends GaeaRenderer


@export var tile_map: TileMap :
	set(value):
		tile_map = value
		update_configuration_warnings()
@export var clear_tile_map_on_draw: bool = true
## Erases the cell when an empty tile is found. Recommended: true.
@export var erase_empty_tiles: bool = true


func _draw() -> void:
	if clear_tile_map_on_draw:
		tile_map.clear()
	super._draw()


func _draw_area(area: Rect2i) -> void:
	var terrains: Dictionary

	for x in range(area.position.x, area.end.x + 1):
		for y in range(area.position.y, area.end.y + 1):
			var tile_position := Vector2(x, y)
			if not generator.grid.has(tile_position):
				if not erase_empty_tiles:
					continue

				for l in range(tile_map.get_layers_count()):
					tile_map.erase_cell(l, Vector2(x, y))

				continue

			var tile = tile_position
			var tile_info = generator.grid[tile_position]
			if not (tile_info is TileInfo):
				continue

			match tile_info.type:
				TileInfo.Type.SINGLE_CELL:
					tile_map.set_cell(
						tile_info.layer, tile, tile_info.source_id,
						tile_info.atlas_coord, tile_info.alternative_tile
					)
				TileInfo.Type.TERRAIN:
					if not terrains.has(tile_info):
						terrains[tile_info] = [tile]
					else:
						terrains[tile_info].append(tile)

	for tile_info in terrains:
		tile_map.set_cells_terrain_connect(
			tile_info.layer, terrains[tile_info],
			tile_info.terrain_set, tile_info.terrain
		)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray

	warnings.append_array(super._get_configuration_warnings())

	if not is_instance_valid(tile_map):
		warnings.append("Needs a TileMap to work.")

	return warnings
