@tool
extends GaeaGraphNode


@onready var _edge_param: SpinBox = $HBoxContainer/EdgeParam


func get_data(idx: int) -> Dictionary:
	var data_input_node: GaeaGraphNode = get_connected_input_node(0)
	var value_data: Dictionary = data_input_node.get_data(get_from_port(0))
	var edge: float = _edge_param.get_param_value()
	var data: Dictionary
	for cell in value_data:
		if value_data[cell] > edge:
			data[cell] = 1.0
		else:
			data[cell] = 0.0
	return data


func get_save_data() -> Dictionary:
	var dictionary: Dictionary = super()
	dictionary["edge"] = _edge_param.get_param_value()
	return dictionary


func load_save_data(data: Dictionary) -> void:
	super(data)
	_edge_param.set_param_value(data["edge"])
