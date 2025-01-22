@tool
extends GaeaGraphNode


@onready var _size_parameter: HBoxContainer = $SizeParameter/VectorParameter
@onready var _number_parameter: SpinBox = $ValueParameter/NumberParameter


func get_data(idx: int) -> Dictionary:
	var dictionary: Dictionary
	for x in range(_generator.world_size.x):
		for y in range(_generator.world_size.y):
			dictionary[Vector2(x, y)] = args["value"]
	return dictionary


func get_save_data() -> Dictionary:
	var dictionary: Dictionary = super()
	dictionary["size"] = _size_parameter.get_param_value()
	dictionary["value"] = _number_parameter.get_param_value()
	return dictionary


func load_save_data(data: Dictionary) -> void:
	super(data)
	_number_parameter.set_param_value(data["value"])
	_size_parameter.set_param_value(data["size"])
