@tool
extends GaeaNodeResource



func get_data(output_port: int, area: Rect2i, generator_data: GaeaData) -> Dictionary:
	# TODO: Get generator's seed instead of random one.
	var _noise: FastNoiseLite = FastNoiseLite.new()
	_noise.seed = randi()

	_noise.frequency = get_arg("frequency", generator_data)
	_noise.fractal_octaves = get_arg("octaves", generator_data)
	_noise.fractal_lacunarity = get_arg("lacunarity", generator_data)
	var dictionary: Dictionary
	for x in get_axis_range(Axis.X, area):
		for y in get_axis_range(Axis.Y, area):
			dictionary[Vector2i(x, y)] = _noise.get_noise_2d(x, y)
	return dictionary
