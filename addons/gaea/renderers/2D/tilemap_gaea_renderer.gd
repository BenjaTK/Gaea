@tool
class_name TilemapGaeaRenderer
extends GaeaRenderer2D
## Uses the [param tile_map] to draw the generator's [param grid].
##
## Takes [TilemapTileInfo] to determine which tile to place
## in every cell.

enum NodeType {
	TILEMAP_LAYERS, ## Use [TileMapLayer]s, with an array of them determining which one is which.
	TILEMAP ## Use a single [TileMap] node (not recommended by Godot).
}

@export var node_type: NodeType = NodeType.TILEMAP_LAYERS :
	set(value):
		node_type = value
		notify_property_list_changed()
@export var tile_map_layers: Array[TileMapLayer] :
	set(value):
		tile_map_layers = value
		update_configuration_warnings()
@export var tile_map: TileMap :
	set(value):
		tile_map = value
		update_configuration_warnings()
@export var clear_tile_map_on_draw: bool = true
## Erases the cell when an empty tile is found in all layers. Recommended: [code]true[/code].
@export var erase_empty_tiles: bool = true
## Set this to [code]true[/code] if you have gaps between your terrains. Can cause problems.
@export var terrain_gap_fix: bool = false


func _ready() -> void:
	super()

	# generators are always required here, this warning serves purpose for both tilemap types
	if !generator:
		push_error("TilemapGaeaRenderer needs a GaeaGenerator node assigned in its exports.")
		return

	match node_type:
		NodeType.TILEMAP:
			if not is_instance_valid(tile_map):
				push_error("TilemapGaeaRenderer needs TileMap to work.")
				return

			if Vector2i(Vector2(tile_map.tile_set.tile_size) * tile_map.scale) != generator.tile_size:
				push_warning("TileMap's tile size doesn't match with generator's tile size, can cause generation issues.
							The generator's tile size has been set to the TileMap's tile size.")
				generator.tile_size = Vector2(tile_map.tile_set.tile_size) * tile_map.scale
		NodeType.TILEMAP_LAYERS:
			if tile_map_layers.is_empty():
				push_error("TilemapGaeaRenderer needs at least one TileMapLayer to work.")
				return

			var layer: TileMapLayer = tile_map_layers.front()
			if Vector2i(Vector2(layer.tile_set.tile_size) * layer.scale) != generator.tile_size:
				push_warning("The TileMapLayer's tile size doesn't match with generator's tile size, can cause generation issues.
							The generator's tile size has been set to the layer's tile size. (Only layer 0 checked)")
				generator.tile_size = Vector2(layer.tile_set.tile_size) * layer.scale


func _draw_area(area: Rect2i) -> void:
	var terrains: Dictionary

	if not is_instance_valid(tile_map) and node_type == NodeType.TILEMAP:
		push_error("Invalid TileMap, can't draw area.")
		return
	elif tile_map_layers.is_empty() and node_type == NodeType.TILEMAP_LAYERS:
		push_error("No TileMapLayers assigned, can't draw area.")
		return

	for x in range(area.position.x, area.end.x + 1):
		for y in range(area.position.y, area.end.y + 1):
			var tile_position := Vector2i(x, y)
			if erase_empty_tiles:
				var has_cell_in_position: bool = false
				for layer in range(generator.grid.get_layer_count()):
					if generator.grid.has_cell(tile_position, layer):
						has_cell_in_position = true
						break

				if not has_cell_in_position:
					for l in range(_get_tilemap_layers_count()):
						_erase_tilemap_cell(l, Vector2i(x, y))
					continue

			for layer in range(generator.grid.get_layer_count()):
				var tile = tile_position
				var tile_info = generator.grid.get_value(tile_position, layer)

				if not (tile_info is TilemapTileInfo):
					continue

				match tile_info.type:
					TilemapTileInfo.Type.SINGLE_CELL:
						_set_tile(tile_position, tile_info)

					TilemapTileInfo.Type.TERRAIN:
						if not terrains.has(tile_info):
							terrains[tile_info] = [tile]
						else:
							terrains[tile_info].append(tile)

	for tile_info in terrains:
		_set_terrain(terrains[tile_info], tile_info)

	(func(): area_rendered.emit(area)).call_deferred()


func _draw() -> void:
	if clear_tile_map_on_draw:
		if node_type == NodeType.TILEMAP:
			tile_map.clear()
		else:
			for layer in tile_map_layers:
				layer.clear()
	super._draw()


func _set_tile(cell: Vector2i, tile_info: TilemapTileInfo) -> void:
	match node_type:
		NodeType.TILEMAP:
			tile_map.call_thread_safe("set_cell", # thread_safe paces these calls out when threaded.
				tile_info.tilemap_layer, cell, tile_info.source_id,
				tile_info.atlas_coord, tile_info.alternative_tile
			)
		NodeType.TILEMAP_LAYERS:
			tile_map_layers[tile_info.tilemap_layer].call_thread_safe("set_cell",
				cell, tile_info.source_id,
				tile_info.atlas_coord, tile_info.alternative_tile
			)


func _set_terrain(cells: Array, tile_info: TilemapTileInfo) -> void:
	match node_type:
		NodeType.TILEMAP:
			tile_map.set_cells_terrain_connect.call_deferred(
					tile_info.tilemap_layer, cells,
					tile_info.terrain_set, tile_info.terrain, !terrain_gap_fix
				)
		NodeType.TILEMAP_LAYERS:
			tile_map_layers[tile_info.tilemap_layer].set_cells_terrain_connect.call_deferred(
					cells, tile_info.terrain_set, tile_info.terrain, !terrain_gap_fix
				)


func _get_tilemap_layers_count() -> int:
	match node_type:
		NodeType.TILEMAP:
			return tile_map.get_layers_count()
		NodeType.TILEMAP_LAYERS:
			return tile_map_layers.size()
	return 0


func _erase_tilemap_cell(layer: int, cell: Vector2i) -> void:
	match node_type:
		NodeType.TILEMAP:
			tile_map.call_thread_safe("erase_cell", layer, cell) # thread_safe paces these calls out when threaded.
		NodeType.TILEMAP_LAYERS:
			tile_map_layers[layer].call_thread_safe("erase_cell", cell)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray

	warnings.append_array(super._get_configuration_warnings())

	if not is_instance_valid(tile_map) and node_type == NodeType.TILEMAP:
		warnings.append("Needs a TileMap to work.")
	elif tile_map_layers.is_empty() and node_type == NodeType.TILEMAP_LAYERS:
		warnings.append("Needs at least one TileMapLayer to work.")

	return warnings


func _validate_property(property: Dictionary) -> void:
	if property.name == "tile_map" and node_type == NodeType.TILEMAP_LAYERS:
		property.usage = PROPERTY_USAGE_NONE
	elif property.name == "tile_map_layers" and node_type == NodeType.TILEMAP:
		property.usage = PROPERTY_USAGE_NONE
