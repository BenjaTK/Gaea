@tool
class_name GaeaGenerator extends Node2D
## Base class for the Gaea addon's procedural generator.


enum TileMode {
	SINGLE_CELL, ## Tile is just a single cell in the TileMap. Requires a [param source_id] and a [param atlas_coord]. Can optionally be an [param alternative_tile].
	TERRAIN ## Tile is a terrain from a terrain set. Allows for autotiling. Requires a [param terrain_set] and a [param terrain]
	}

enum Tiles { WALL, FLOOR, EMPTY = -1 }

signal generation_finished

const NEIGHBORS := [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN,
					Vector2(1, 1), Vector2(1, -1), Vector2(-1, -1), Vector2(-1, 1)]

@export var tileMap: TileMap
## If [code]true[/code] regenerates on [code]_ready()[/code].
## If [code]false[/code] and a world was generated in the editor,
## it will be kept.
@export var regenerateOnReady: bool = true
## If [code]false[/code], the tile size will be set to the [TileSet]'s
## tile size.
@export var overrideTileSize: bool = false :
	set(value):
		overrideTileSize = value
		notify_property_list_changed()
var floorTileMode: TileMode = TileMode.SINGLE_CELL :
	set(value):
		floorTileMode = value
		notify_property_list_changed()
## The [TileMap] layer the floor tiles will be placed in.
var floorLayer: int = 0
## A [TileSetSource] identifier. See [method TileSet.set_source_id].[br]If set to [code]-1[/code], the cell will be erased.
var floorSourceId: int = 0
## Identifies a tile's coordinates in the atlas (if the source is a [TileSetAtlasSource]).
## For [TileSetScenesCollectionSource] it should always be [code]Vector2i(0, 0)[/code]).[br]If set to [code]Vector2i(-1, -1)[/code], the cell will be erased.
var floorAtlasCoord: Vector2i = Vector2i.ZERO
## Identifies a tile alternative in the atlas (if the source is a [TileSetAtlasSource]),
## and the scene for a [TileSetScenesCollectionSource].[br]If set to [code]-1[/code], the cell will be erased.
var floorAlternativeTile: int = 0
## The floor's terrain set in the [TileMap].
var floorTerrainSet: int = 0
## Terrain in the terrain set determined previously.
var floorTerrain: int = 0

var wallTileMode: TileMode = TileMode.SINGLE_CELL :
	set(value):
		wallTileMode = value
		notify_property_list_changed()
## The [TileMap] layer the wall tiles will be placed in.
var wallLayer: int = 0
## A [TileSetSource] identifier. See [method TileSet.set_source_id].[br]If set to [code]-1[/code], the cell will be erased.
var wallSourceId: int = 0
## Identifies a tile's coordinates in the atlas (if the source is a [TileSetAtlasSource]).
## For [TileSetScenesCollectionSource] it should always be [code]Vector2i(0, 0)[/code]).[br]If set to [code]Vector2i(-1, -1)[/code], the cell will be erased.
var wallAtlasCoord: Vector2i = Vector2i.ZERO
## Identifies a tile alternative in the atlas (if the source is a [TileSetAtlasSource]),
## and the scene for a [TileSetScenesCollectionSource].[br]If set to [code]-1[/code], the cell will be erased.
var wallAlternativeTile: int = 0
## The wall's terrain set in the [TileMap].
var wallTerrainSet: int = 0
## Terrain in the terrain set determined previously.
var wallTerrain: int = 0

var tileSize: Vector2 = Vector2.ZERO

var grid : Dictionary


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	if not overrideTileSize:
		tileSize = Vector2(tileMap.tile_set.tile_size)

	if regenerateOnReady:
		generate()


func generate() -> void:
	return


func _draw_tiles() -> void:
	for tile in grid:
		match grid[tile]:
			Tiles.FLOOR:
				if floorTileMode == TileMode.SINGLE_CELL:
					tileMap.set_cell(floorLayer, tile, floorSourceId, floorAtlasCoord, floorAlternativeTile)
				elif floorTileMode == TileMode.TERRAIN:
					tileMap.set_cells_terrain_connect(floorLayer, [tile], floorTerrainSet, floorTerrain)
			Tiles.WALL:
				if wallTileMode == TileMode.SINGLE_CELL:
					tileMap.set_cell(wallLayer, tile, wallSourceId, wallAtlasCoord, wallAlternativeTile)
				elif wallTileMode == TileMode.TERRAIN:
					tileMap.set_cells_terrain_connect(wallLayer, [tile], wallTerrainSet, wallTerrain)


func erase() -> void:
	tileMap.clear()
	grid.clear()


### Utils ###


func map_to_world(tile: Vector2) -> Vector2:
	return tile * tileSize + tileSize / 2


static func are_all_neighbors_of_type(grid: Dictionary, pos: Vector2, type: Tiles) -> bool:
	for neighbor in NEIGHBORS:
		if not grid.has(pos + neighbor):
			continue

		if grid[pos + neighbor] != type:
			return false

	return true


static func get_neighbor_count_of_type(grid: Dictionary, pos: Vector2, type: Tiles) -> int:
	var count = 0

	for neighbor in NEIGHBORS:
		if not grid.has(pos + neighbor):
			if type == Tiles.EMPTY:
				count += 1
			continue

		if grid[pos + neighbor] == type:
			count += 1

	return count


static func get_neighbor_count_of_types(grid: Dictionary, pos: Vector2, types: Array[Tiles]) -> int:
	var count = 0

	for neighbor in NEIGHBORS:
		if not grid.has(pos + neighbor):
			if types.has(Tiles.EMPTY):
				count += 1
			continue

		if grid[pos + neighbor] in types:
			count += 1

	return count


static func get_tiles_of_type(type: Tiles, grid: Dictionary) -> Array[Vector2]:
	var tiles: Array[Vector2] = []
	for tile in grid:
		if grid[tile] == type:
			tiles.append(tile)

	return tiles


### Editor ###


func _get_property_list() -> Array[Dictionary]:
	var properties : Array[Dictionary]
	if overrideTileSize:
		properties.append({
			"name": "tileSize",
			"usage": PROPERTY_USAGE_DEFAULT,
			"type": TYPE_VECTOR2I,
		})
	properties.append_array(_get_tile_properties("floor"))
	properties.append_array(_get_tile_properties("wall"))

	return properties


func _get_tile_properties(prefix: String) -> Array[Dictionary]:
	var properties: Array[Dictionary]
	properties.append_array([
		{
			"name": prefix.capitalize(),
			"usage": PROPERTY_USAGE_GROUP,
			"type": TYPE_NIL
		},
		{
			"name": prefix + "TileMode",
			"usage": PROPERTY_USAGE_DEFAULT,
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": "Single Cell,Terrain"
		},
		{
			"name": prefix + "Layer",
			"usage": PROPERTY_USAGE_DEFAULT,
			"type": TYPE_INT,
		}
	])

	match (floorTileMode if prefix == "floor" else wallTileMode):
		TileMode.SINGLE_CELL:
			properties.append_array([
				{
					"name": prefix + "SourceId",
					"usage": PROPERTY_USAGE_DEFAULT,
					"type": TYPE_INT
				},
				{
					"name": prefix + "AtlasCoord",
					"usage": PROPERTY_USAGE_DEFAULT,
					"type": TYPE_VECTOR2I
				},
				{
					"name": prefix + "AlternativeTile",
					"usage": PROPERTY_USAGE_DEFAULT,
					"type": TYPE_INT
				}
			])
		TileMode.TERRAIN:
			properties.append_array([
				{
					"name": prefix + "TerrainSet",
					"usage": PROPERTY_USAGE_DEFAULT,
					"type": TYPE_INT
				},
				{
					"name": prefix + "Terrain",
					"usage": PROPERTY_USAGE_DEFAULT,
					"type": TYPE_INT
				},
			])
	return properties


func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray

	if not is_instance_valid(tileMap):
		warnings.append("TileMap is required to generate.")

	return warnings
