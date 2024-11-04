@tool
extends GaeaGraphNode


@onready var _size_parameter: HBoxContainer = $SizeParameter/VectorParameter
@onready var _number_parameter: SpinBox = $ValueParameter/NumberParameter


func get_data(idx: int) -> Dictionary:
	var dictionary: Dictionary
	var _size: Vector2 = _size_parameter.get_param_value()
	for x in range(_size.x):
		for y in range(_size.y):
			dictionary[Vector2(x, y)] = _number_parameter.get_param_value()
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
