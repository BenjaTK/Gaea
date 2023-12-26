@tool
class_name NoiseGeneratorSettings
extends GeneratorSettings2D

## An array of [param NoiseGeneratorData] with thresholds that go from [code]-1.0[/code] to [code]1.0[/code], and [param tile] (as [param TileInfo]).[br]

@export var tiles: Array[NoiseGeneratorData]:
## I have realized that the order matters a lot so I
## restored the sorting
	set(value):
		## If the last element of the array is not a [param NoiseGeneratorData],
		## then create a new one.
		var last_element = value[-1]
		value[-1] = last_element if last_element is NoiseGeneratorData else NoiseGeneratorData.new()

		value.sort_custom(func sort_descending(a, b): return a.threshold > b.threshold)

		tiles = value

@export var noise: FastNoiseLite = FastNoiseLite.new()
@export var random_noise_seed := true
## Infinite worlds only work with a [ChunkLoader].
@export var infinite: bool = false
@export var world_size: Vector2i = Vector2i(256, 256):
	set(value):
		world_size = value
		if is_instance_valid(falloff_map):
			falloff_map.size = world_size
@export_group("Falloff", "falloff_")
## Enables the usage of a [FalloffMap], which makes tiles
## farther away from the center be lower in the heightmap,
## forming islands. Doesn't work if [param infinite] is [code]true[/code].
@export var falloff_enabled: bool = false
## Enables the usage of a [FalloffMap], which makes tiles
## farther away from the center be lower in the heightmap,
## forming islands. Doesn't work if [param infinite] is [code]true[/code].
@export var falloff_map: FalloffMap:
	set(value):
		falloff_map = value
		if falloff_map != null:
			falloff_map.size = world_size
