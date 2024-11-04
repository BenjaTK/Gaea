@tool
extends GaeaGraphNode


var _noise: FastNoiseLite = FastNoiseLite.new()


@onready var _preview: TextureRect = $Preview
@onready var _frequency_param: SpinBox = $HBoxContainer/FrequencyParam
@onready var _octaves_param: SpinBox = $HBoxContainer2/OctavesParam
@onready var _lacunarity_param: SpinBox = $HBoxContainer3/LacunarityParam
@onready var _size_parameter: HBoxContainer = $HBoxContainer4/Size


func _ready() -> void:
	_update_preview()


func _update_preview() -> void:
	_noise.frequency = _frequency_param.get_param_value()
	_noise.fractal_octaves = _octaves_param.get_param_value()
	_noise.fractal_lacunarity = _lacunarity_param.get_param_value()
	_preview.texture = ImageTexture.create_from_image(_noise.get_seamless_image(144, 144))


func get_data(idx: int) -> Dictionary:
	_noise.seed = _generator.seed

	_noise.frequency = _frequency_param.get_param_value()
	_noise.fractal_octaves = _octaves_param.get_param_value()
	_noise.fractal_lacunarity = _lacunarity_param.get_param_value()
	_preview.texture = ImageTexture.create_from_image(_noise.get_seamless_image(144, 144))

	var dictionary: Dictionary
	for x in range(_generator.world_size.x):
		for y in range(_generator.world_size.y):
			dictionary[Vector2(x, y)] = _noise.get_noise_2d(x, y)
	return dictionary


func get_save_data() -> Dictionary:
	var dictionary: Dictionary = super()
	dictionary["frequency"] = _frequency_param.get_param_value()
	dictionary["fractal_octaves"] = _octaves_param.get_param_value()
	dictionary["fractal_lacunarity"] = _lacunarity_param.get_param_value()
	return dictionary


func load_save_data(data: Dictionary) -> void:
	super(data)
	_frequency_param.set_param_value(data["frequency"])
	_octaves_param.set_param_value(data["fractal_octaves"])
	_lacunarity_param.set_param_value(data["fractal_lacunarity"])
