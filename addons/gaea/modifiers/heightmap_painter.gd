@tool
@icon("heightmap_painter.svg")
class_name HeightmapPainter
extends Modifier
## Replaces tiles in the map with [param tile] based on a noise heightmap.


@export var noise: FastNoiseLite = FastNoiseLite.new()
@export var random_noise_seed := true
@export var tile: TileInfo
## The medium height at which the painter will start replacing tiles.
## The heightmap displaces this height by a random number
## between -[param height_intensity] and [param height_intensity].
@export var height_offset := 128
## The heightmap displaces [param height_offset] by a random number
## from -[param height_intensity] to [param height_intensity].
@export var height_intensity := 20


func apply(grid: Dictionary, generator: GaeaGenerator) -> Dictionary:
	if random_noise_seed:
		noise.seed = randi()

	for tile_pos in grid.keys():
		var height = floor(noise.get_noise_1d(tile_pos.x) * height_intensity + height_offset)
		if tile_pos.y >= -height:
			grid[tile_pos] = tile
	return grid
