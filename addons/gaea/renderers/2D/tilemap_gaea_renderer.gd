@tool
class_name TilemapGaeaRenderer
extends GaeaRenderer2D
## Uses the [param tile_map] to draw the generator's [param grid].
##
## Takes [TilemapTileInfo] to determine which tile to place
## in every cell.

@export var tile_map: TileMap:
	set(value):
		tile_map = value
		update_configuration_warnings()
@export var clear_tile_map_on_draw: bool = true
## Erases the cell when an empty tile is found. Recommended: true.
@export var erase_empty_tiles: bool = true


func _ready() -> void:
	super()
	generator.tile_map = tile_map
	# if Vector2i(Vector2(tile_map.tile_set.tile_size) * tile_map.scale) != generator.tile_size:
	# 	push_warning("TileMap's tile size doesn't match with generator's tile size, can cause generation issues.
	# 				The generator's tile size has been set to the TileMap's tile size.")
	# 	generator.tile_size = Vector2(tile_map.tile_set.tile_size) * tile_map.scale
	# if tile_map.tile_set.tile_shape != generator.tile_shape:
	# 	push_warning("TileMap's tile shape doesn't match with generator's tile shape, can cause chunk generation issues.
	# 				The generator's tile shape has been set to the TileMap's tile shape.")
	# 	generator.tile_shape = tile_map.tile_set.tile_shape
	# if tile_map.tile_set.tile_offset_axis != generator.tile_offset_axis:
	# 	push_warning("TileMap's tile offset axis doesn't match with generator's tile offset axis, can cause chunk generation issues.
	# 				The generator's tile offset axis has been set to the TileMap's tile offset axis.")
	# 	generator.tile_offset_axis = tile_map.tile_set.tile_offset_axis


func _draw_area(chunk_position) -> void:
	print(chunk_position is Vector2i)
	print(chunk_position)
	if generator.tile_shape == TileSet.TILE_SHAPE_HEXAGON and chunk_position is Vector2i:
		_draw_hex_area(generator.get_cells(chunk_position, generator.chunk_size.x, tile_map))
		return

	var area
	if chunk_position is Rect2i:
		area = chunk_position
	else:
		area = Rect2i(chunk_position * generator.chunk_size, generator.chunk_size)
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
					tile_map.call_thread_safe("erase_cell", l, Vector2i(x, y))  # thread_safe paces these calls out when threaded.
				continue

			for layer in range(generator.grid.get_layer_count()):
				var tile = tile_position
				var tile_info = generator.grid.get_value(tile_position, layer)

				if not (tile_info is TilemapTileInfo):
					continue

				match tile_info.type:
					TilemapTileInfo.Type.SINGLE_CELL:
						tile_map.call_thread_safe(
							"set_cell",  # thread_safe paces these calls out when threaded.
							tile_info.tilemap_layer,
							tile,
							tile_info.source_id,
							tile_info.atlas_coord,
							tile_info.alternative_tile
						)
					TilemapTileInfo.Type.TERRAIN:
						if not terrains.has(tile_info):
							terrains[tile_info] = [tile]
						else:
							terrains[tile_info].append(tile)

	for tile_info in terrains:
		tile_map.set_cells_terrain_connect.call_deferred(
			tile_info.tilemap_layer, terrains[tile_info], tile_info.terrain_set, tile_info.terrain
		)

	(func(): area_rendered.emit(area)).call_deferred()


func _draw_hex_area(cells: Array[Vector2i]) -> void:
	var terrains: Dictionary

	for tile_position in cells:
		var has_cell_in_position: bool = false
		for layer in range(generator.grid.get_layer_count()):
			if generator.grid.has_cell(tile_position, layer):
				has_cell_in_position = true

		if erase_empty_tiles and not has_cell_in_position:
			for l in range(tile_map.get_layers_count()):
				tile_map.call_thread_safe("erase_cell", l, tile_position)  # thread_safe paces these calls out when threaded.
			continue

		for layer in range(generator.grid.get_layer_count()):
			var tile = tile_position
			var tile_info = generator.grid.get_value(tile_position, layer)

			if not (tile_info is TilemapTileInfo):
				continue

			match tile_info.type:
				TilemapTileInfo.Type.SINGLE_CELL:
					tile_map.call_thread_safe(
						"set_cell",  # thread_safe paces these calls out when threaded.
						tile_info.tilemap_layer,
						tile,
						tile_info.source_id,
						tile_info.atlas_coord,
						tile_info.alternative_tile
					)
				TilemapTileInfo.Type.TERRAIN:
					if not terrains.has(tile_info):
						terrains[tile_info] = [tile]
					else:
						terrains[tile_info].append(tile)

	for tile_info in terrains:
		tile_map.set_cells_terrain_connect.call_deferred(
			tile_info.tilemap_layer, terrains[tile_info], tile_info.terrain_set, tile_info.terrain
		)

	(func(): area_rendered.emit(Rect2i(0, 0, 1, 1))).call_deferred()


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
