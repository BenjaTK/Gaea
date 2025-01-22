@tool
extends GaeaGraphNode


@onready var _chance_param: SpinBox = $HBoxContainer/ChanceParam


func get_data(idx: int) -> Dictionary:
	seed(_generator.seed)
	var data_input_node: GaeaGraphNode = get_connected_input_node(0)
	var value_data: Dictionary = data_input_node.get_data(get_from_port(0))
	var chance: float = _chance_param.get_param_value() / 100.0
	var data: Dictionary
	for cell in value_data:
		if randf() < chance:
			data[cell] = value_data[cell]
	return data


func get_save_data() -> Dictionary:
	var dictionary: Dictionary = super()
	dictionary["chance"] = _chance_param.get_param_value()
	return dictionary


func load_save_data(data: Dictionary) -> void:
	super(data)
	_chance_param.set_param_value(data["chance"])
