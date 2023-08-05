@tool
class_name NoiseGeneratorSettings
extends GeneratorSettings


## Dictionary of [param thresholds] (keys) that go from [code]-1.0[/code] to [code]1.0[/code], and [TileInfo] (values).[br]
## The algorithm loops through all thresholds and, if the noise value
## at the coordinate is higher than it, it places the configured tile.[br]
## [br]
## [b]Note:[/b] The dictionary will be automatically sorted in descending
## order and won't accept any keys that aren't [code]floats[/code].
@export var tiles : Dictionary :
	set(value):
		for key in value.keys():
			if not (key is float) or abs(key) > 1.0:
				value.erase(key)

		var sorted_keys := value.keys()
		sorted_keys.sort_custom(func sort_descending(a, b): return a > b)

		var sorted: Dictionary
		for key in sorted_keys:
			var key_value = value[key]
			# Check if it's already a TileInfo, else make a new one.
			sorted[key] = key_value if key_value is TileInfo else TileInfo.new()

		tiles = sorted
@export var noise: FastNoiseLite = FastNoiseLite.new()
@export var random_noise_seed := true
@export var world_size: Vector2i = Vector2i(256, 256)
