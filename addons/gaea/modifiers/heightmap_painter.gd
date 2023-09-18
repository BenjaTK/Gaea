@tool
@icon("heightmap_painter.svg")
class_name HeightmapPainter
extends ChunkAwareModifier
## Replaces tiles in the map with [param tile] based on a noise heightmap.
## @tutorial(Heightmap Painter Modifier): https://benjatk.github.io/Gaea/#/modifiers?id=-heightmap-painter


## Overrides [param noise] in favor of using the generator's noise (if it has one).[br]
## Useful for use with the [HeightmapGenerator2D], as it will make sure it follows
## the same terrain shape (especially if [param height_intensity] is the same as the generator's).
@export var use_generator_noise: bool = true
@export var noise: FastNoiseLite = FastNoiseLite.new()
@export var random_noise_seed := true
@export var tile: TileInfo
## The medium height at which the painter will start replacing tiles.
## The heightmap displaces this height by a random number
## between -[param height_intensity] and [param height_intensity].[br]
## Negative values will go below y=0.
@export var height_offset := 128
## The heightmap displaces [param height_offset] by a random number
## from -[param height_intensity] to [param height_intensity].
@export var height_intensity := 20


func _apply_area(area: Rect2i, grid: Dictionary, _generator: GaeaGenerator) -> Dictionary:
	for x in range(area.position.x, area.end.x + 1):
		for y in range(area.position.y, area.end.y + 1):
			var tile_pos := Vector2(x, y)
			if not grid.has(tile_pos):
				continue


			var height = floor(noise.get_noise_1d(tile_pos.x) * height_intensity + height_offset)
			if tile_pos.y >= -height:
				if not _passes_filter(grid[tile_pos]):
					continue

				grid[tile_pos] = tile

	return grid
