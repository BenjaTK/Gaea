@tool
@icon("carver.svg")
class_name Carver
extends Modifier


const MAX_HEIGHT_RANDOM_MULTIPLIER := 10.0

@export var noise: FastNoiseLite = FastNoiseLite.new()
@export var random_noise_seed := true
## Any values in the noise texture that go above this threshold
## will be deleted from the map. (-1.0 is black, 1.0 is white)[br]
## Lower values mean more empty areas.
@export_range(-1.0, 1.0) var threshold := 0.15
## Max height that the carving will take effect in.
@export var max_height := 128
## Adds some noise-based randomness to the max height to make transitions
## more natural. This randomness only goes downwards, so [param max_height]
## will still be the max height.
@export_range(0.0, 1.0) var max_height_random := 1.0


func apply(grid: Dictionary, _generator: GaeaGenerator) -> Dictionary:
	if random_noise_seed:
		noise.seed = randi()

	for tile in grid.keys():
		# Add random variation to the max height to make the transition more natural.
		# Needs a better way of doing this though.
		if tile.y < -max_height + floor(
				abs(noise.get_noise_1d(tile.x))
				* MAX_HEIGHT_RANDOM_MULTIPLIER * max_height_random):
			continue

		if noise.get_noise_2d(tile.x, tile.y) > threshold:
			grid.erase(tile)

	return grid
