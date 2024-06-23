class_name WaveFunction2DEntry
extends Resource
## Describes a [TileInfo] and which tiles can neighbor it.
## @experimental

## The [TileInfo] to be placed when this entry is chosen. Make sure
## to set its [param id] so other entries can detect it.
@export var tile_info: TileInfo
## A higher weight means a higher chance of being chosen to be placed.
@export var weight: float = 1.0
@export_group("Valid Neighbors", "neighbors_")
## Valid neighbors above the tile, using their [TileInfo]'s [param id].
## Can include this [param tile_info]'s [param id].
@export var neighbors_up: Array[StringName]
## Valid neighbors below the tile, using their [TileInfo]'s [param id].
## Can include this [param tile_info]'s [param id].
@export var neighbors_down: Array[StringName]
## Valid neighbors left to the tile, using their [TileInfo]'s [param id].
## Can include this [param tile_info]'s [param id].
@export var neighbors_left: Array[StringName]
## Valid neighbors right to the tile, using their [TileInfo]'s [param id].
## Can include this [param tile_info]'s [param id].
@export var neighbors_right: Array[StringName]
