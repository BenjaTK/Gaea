@tool
class_name Walls extends Modifier
## Adds [param tileInfo] below any tile that isn't the Generator's [param defaultTileInfo].
## Useful for tilesets whose walls are different tiles from the ceiling.


## The tile to be placed. Will be placed below any tile
## that isn't the Generator's [param defaultTileInfo].
@export var tileInfo: TileInfo


func apply(grid: Dictionary, generator: GaeaGenerator) -> Dictionary:
	var newGrid := grid.duplicate()
	for tile in grid:
		if grid[tile] == generator.defaultTileInfo:
			var above = tile + Vector2.UP
			if grid.has(above) and grid[above] != generator.defaultTileInfo:
				newGrid[tile] = tileInfo

	return newGrid
