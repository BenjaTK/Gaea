@tool
@icon("carver.svg")
class_name Carver
extends Modifier
## Uses noise to remove certain tiles from the map.


@export var noise: FastNoiseLite = FastNoiseLite.new()
@export var random_noise_seed := true
## Any values in the noise texture that go above this threshold
## will be deleted from the map. (-1.0 is black, 1.0 is white)[br]
## Lower values mean more empty areas.
@export_range(-1.0, 1.0) var threshold := 0.15
@export_group("Bounds")
## Leave any or both axis as [code]inf[/code] to not have any limits.
@export var max := Vector2(INF, INF)
## Leave any or both axis as [code]-inf[/code] to not have any limits.
@export var min := Vector2(-INF, -INF)


func apply(grid: Dictionary, _generator: GaeaGenerator) -> Dictionary:
	if random_noise_seed:
		noise.seed = randi()

	for tile_pos in grid.keys():

		if _is_out_of_bounds(tile_pos):
			continue

		if noise.get_noise_2d(tile_pos.x, tile_pos.y) > threshold:
			grid.erase(tile_pos)

	return grid


func apply_chunk(grid: Dictionary, generator: GaeaGenerator, chunk_position: Vector2i) -> Dictionary:
	if random_noise_seed:
		noise.seed = randi()
	
	for x in GaeaGenerator.get_chunk_range(chunk_position.x):
		for y in GaeaGenerator.get_chunk_range(chunk_position.y):
			var tile_pos := Vector2(x, y)
			if not grid.has(tile_pos):
				continue
			
			if noise.get_noise_2d(tile_pos.x, tile_pos.y) > threshold:
				grid.erase(tile_pos)
	
	return grid


func _is_out_of_bounds(tile_pos: Vector2) -> bool:
	return (tile_pos.x > max.x or tile_pos.y > max.y or
			tile_pos.x < min.x or tile_pos.y < min.y)
