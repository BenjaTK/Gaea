@tool
extends GaeaGraphNode


@onready var _tile_info_input: HBoxContainer = $TileInfoInput
@onready var _min_threshold: SpinBox = $HBoxContainer/SpinBox
@onready var _max_threshold: SpinBox = $HBoxContainer2/SpinBox


func get_data(idx: int) -> Dictionary:
	var data_input_node: GaeaGraphNode = get_connected_input_node(0)
	var value_data: Dictionary = data_input_node.get_data(get_from_port(0))
	if idx == 0:
		return value_data

	var data: Dictionary
	var tile_info: Resource = get_connected_input_node(1).get_data(get_from_port(1)).value
	var min: float = _min_threshold.get_param_value()
	var max: float = _max_threshold.get_param_value()

	for cell in value_data.keys():
		var value: float = value_data[cell]
		if value >= min and value <= max:
			data[cell] = tile_info
		else:
			data[cell] = null

	return data


func get_save_data() -> Dictionary:
	var dictionary: Dictionary = super()
	dictionary["min"] = _min_threshold.get_param_value()
	dictionary["max"] = _max_threshold.get_param_value()
	return dictionary


func load_save_data(data: Dictionary) -> void:
	super(data)
	_min_threshold.set_param_value(data["min"])
	_max_threshold.set_param_value(data["max"])
