@tool
class_name GaeaGenerator extends Node2D
## Base class for the Gaea addon's procedural generator.


signal generation_finished

const NEIGHBORS := [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN,
					Vector2(1, 1), Vector2(1, -1), Vector2(-1, -1), Vector2(-1, 1)]

## If [code]true[/code], allows for generating a preview of the generation
## in the editor. Useful for debugging.
@export var preview: bool = false :
	set(value):
		preview = value
		if value == false:
			erase()
@export var tileMap: TileMap
## If [code]true[/code] regenerates on [code]_ready()[/code].
## If [code]false[/code] and a world was generated in the editor,
## it will be kept.
@export var regenerateOnReady: bool = true
## If [code]false[/code], the tilemap will not be cleared when generating.
@export var clearTilemapOnGeneration: bool = true

var tileSize : Vector2

var grid : Dictionary


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	tileSize = tileMap.tile_set.tile_size

	if regenerateOnReady:
		generate()


func generate() -> void:
	if not is_instance_valid(tileMap):
		push_error("%s doesn't have a TileMap" % name)
		return


func _draw_tiles() -> void:
	for tile in grid:
		var tileInfo = grid[tile]
		if not (tileInfo is TileInfo):
			continue

		match tileInfo.type:
			TileInfo.Type.SINGLE_CELL:
				tileMap.set_cell(
					tileInfo.layer, tile, tileInfo.sourceId,
					tileInfo.atlasCoord, tileInfo.alternativeTile
				)
			TileInfo.Type.TERRAIN:
				tileMap.set_cells_terrain_connect(
					tileInfo.layer, [tile],
					tileInfo.terrainSet, tileInfo.terrain
				)


func erase(clearTilemap := true) -> void:
	if clearTilemap:
		tileMap.clear()
	grid.clear()


func _apply_modifiers(modifiers: Array[Modifier]) -> void:
	for modifier in modifiers:
		if not (modifier is Modifier):
			continue

		grid = modifier.apply(grid, self)


### Utils ###


func map_to_world(tile: Vector2) -> Vector2:
	return tile * tileSize + tileSize / 2


static func are_all_neighbors_of_type(grid: Dictionary, pos: Vector2, type: TileInfo) -> bool:
	for neighbor in NEIGHBORS:
		if not grid.has(pos + neighbor):
			continue

		if grid[pos + neighbor] != type:
			return false

	return true


static func get_neighbor_count_of_type(grid: Dictionary, pos: Vector2, type: TileInfo) -> int:
	var count = 0

	for neighbor in NEIGHBORS:
		if not grid.has(pos + neighbor):
			if type == null:
				count += 1
			continue

		if grid[pos + neighbor] == type:
			count += 1

	return count


static func get_tiles_of_type(type: TileInfo, grid: Dictionary) -> Array[Vector2i]:
	var tiles: Array[Vector2i] = []
	for tile in grid:
		if grid[tile] == type:
			tiles.append(tile)

	return tiles


### Editor ###


func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray

	if not is_instance_valid(tileMap):
		warnings.append("TileMap is required to generate.")

	return warnings
