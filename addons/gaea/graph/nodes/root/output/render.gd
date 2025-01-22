@tool
extends GaeaNodeResource


func execute(area: Rect2i, generator_data: GaeaData, generator: GaeaGenerator) -> void:
	var map_input_resource: GaeaNodeResource = generator_data.resources[get_connected_resource_idx(0)]
	var grid_data: Dictionary = map_input_resource.get_data(
			get_connected_port_to(0), area, generator_data
		)
	generator.generation_finished.emit(
		grid_data
	)
