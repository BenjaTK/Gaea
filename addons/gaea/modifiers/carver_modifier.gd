@tool
@icon("carver_modifier.svg")
class_name Carver extends Modifier


const MAX_HEIGHT_RANDOM_MULTIPLIER := 10.0

@export var noise: FastNoiseLite
@export var randomNoiseSeed := true
## Any values in the noise texture that go above this threshold
## will be deleted from the map. (-1.0 is black, 1.0 is white)[br]
## Lower values mean more empty areas.
@export_range(-1.0, 1.0) var threshold := 0.15
## Max height that the carving will take effect in.
@export var maxHeight := 128
## Adds some noise-based randomness to the max height to make transitions
## more natural. This randomness only goes downwards, so [param maxHeight]
## will still be the max height.
@export_range(0.0, 1.0) var maxHeightRandom := 1.0


func apply(grid: Dictionary) -> Dictionary:
	if randomNoiseSeed:
		noise.seed = randi()
	for tile in grid.keys():
		# Add random variation to the max height to make the transition more natural.
		# Needs a better way of doing this though.
		if tile.y < -maxHeight + floor(abs(noise.get_noise_1d(tile.x)) * MAX_HEIGHT_RANDOM_MULTIPLIER * maxHeightRandom):
			continue

		if noise.get_noise_2d(tile.x, tile.y) > threshold:
			grid.erase(tile)

	return grid
