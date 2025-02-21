@tool
@icon("generate_borders.svg")
class_name UnrollPatterns
extends Modifier2D

@export var tile_set : TileSet

var _temp_grid: GaeaGrid

func apply(grid: GaeaGrid, generator: GaeaGenerator) -> void:
	# Check if the generator has a "settings" variable and if those
	# settings have a "tile" variable.
	if not generator.get("settings") or not generator.settings.get("tile"):
		push_warning("GenerateBorder modifier not compatible with %s" % generator.name)
		return
	
	_temp_grid = grid.clone()

	# For each coord in the affected layers...
	for layer in affected_layers:
		for coord in grid.get_cells(layer):
			var tile_info:TilemapTileInfo = grid.get_value(coord, layer)
			# Ignore invalid tiles...
			if not _passes_filter(grid, coord):
				return
			# Find patterns...
			if tile_info.type == TilemapTileInfo.Type.PATTERN:
				if tile_set.get_patterns_count() > tile_info.pattern_idx:
					var pattern:TileMapPattern = tile_set.get_pattern(tile_info.pattern_idx)
					# And for each pattern cell...
					for cell in pattern.get_used_cells():
						var new_info:TilemapTileInfo = _get_from_pool(cell, pattern, tile_info, generator)
						# Set the corresponding grid cell!
						_temp_grid.set_value(coord + cell + tile_info.pattern_offset, new_info, layer)
	
	generator.grid = _temp_grid.clone()
	_temp_grid.unreference()

func _get_from_pool(cell:Vector2i, pattern:TileMapPattern, tile_info:TilemapTileInfo, generator:GaeaGenerator2D):
	var tile_layer = tile_info.tilemap_layer
	var alt_tile = pattern.get_cell_alternative_tile(cell)
	var atlas = pattern.get_cell_atlas_coords(cell)
	var source = pattern.get_cell_source_id(cell)
	
	for tile in generator.tile_pool:
		var valid_layer = tile.tilemap_layer == tile_layer
		var valid_alt = tile.alternative_tile == alt_tile
		var valid_atlas = tile.atlas_coord == atlas
		var valid_source = tile.source_id == source
		var valid_id = tile.id == tile_info.id
		if valid_layer and valid_alt and valid_atlas and valid_source and valid_id:
			return tile
	
	var new_info:TilemapTileInfo = TilemapTileInfo.new()
	new_info.tilemap_layer = tile_layer
	new_info.alternative_tile = alt_tile
	new_info.atlas_coord = atlas
	new_info.source_id = source
	new_info.id = tile_info.id
	generator.tile_pool.append(new_info)
	
	return new_info
