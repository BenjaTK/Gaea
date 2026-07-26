@tool
class_name GaeaNodeOutput
extends GaeaNodeResource
## Outputs the generated grid via [signal GaeaGenerator.generation_finished].
##
## All Gaea graphs should lead to this node. When a generation is needed,
## [method execute] is called in the corresponding graph's Output node. This method
## uses [method traverse] to get the generated grid for each layer, constructs a
## [GaeaResult] object with it and finally emits the [signal GaeaGenerator.generation_finished] signal
## to pass that grid to listener nodes.[br][br]
## This node can't and shouldn't be deleted.


func _get_title() -> String:
	return "Output"


func _get_arguments_list() -> Array[StringName]:
	var layers: Array[StringName] = []
	if is_instance_valid(graph):
		for layer_idx in graph.layers.size():
			layers.append(&"%d" % layer_idx)
	return layers


func _get_argument_type(arg_name: StringName) -> GaeaValue.Type:
	if not is_instance_valid(graph):
		return GaeaValue.Type.NULL # Default to NULL just in case.

	var idx: int = int(arg_name)
	if graph.layers.size() < idx:
		return GaeaValue.Type.NULL

	var layer: GaeaLayer = graph.layers.get(idx)

	if not is_instance_valid(layer):
		return GaeaValue.Type.NULL

	return layer.type as GaeaValue.Type


func _get_argument_display_name(arg_name: StringName) -> String:
	var idx: int = int(arg_name)
	if graph.layers.size() < idx:
		return "Invalid Layer"

	var layer: GaeaLayer = graph.layers.get(idx)

	if not is_instance_valid(layer):
		return "[color=RED](%d) Missing GaeaLayer resource[/color]" % idx

	var layer_name: String
	if not layer.resource_name.is_empty():
		layer_name = "(%d) %s" % [idx, layer.resource_name]
	else:
		layer_name = "(%d) Layer %s" % [idx, idx]

	if not layer.enabled:
		layer_name = "[color=DIM_GRAY][s]%s[/s][/color]" % layer_name

	return layer_name


func _get_argument_connection(arg_name: StringName) -> Dictionary:
	var idx = int(arg_name)
	for connection in connections:
		if connection.to_port == idx:
			return connection
	return {}


func _has_argument_editor(_arg_name: StringName) -> bool:
	return false


## Start generation for [param area], using [param pouch]'s pouch.
func execute(pouch: GaeaGenerationPouch) -> GaeaResult:
	var start_time := Time.get_ticks_msec()
	_log_execute("Start", pouch.area)

	var grid: GaeaResult = GaeaResult.new()
	for layer_idx in graph.layers.size():
		var layer_resource: GaeaLayer = graph.layers.get(layer_idx)
		if not is_instance_valid(layer_resource) or not layer_resource.enabled:
			grid.add_layer(layer_idx, null, layer_resource)
			continue

		_log_layer("Start", layer_idx)

		var layer_data: Variant = _get_arg(&"%d" % layer_idx, pouch)
		grid.add_layer(layer_idx, layer_data, layer_resource)
		traversed.emit(&"%d" % layer_idx, grid, pouch)

		_log_layer("End", layer_idx)

	_log_execute("End", pouch.area)
	_log_time("Generation", Time.get_ticks_msec() - start_time)

	return grid


# Custom scene that dynamically adds layer slots.
func _get_scene_script() -> GDScript:
	return load("uid://34dullcgrsk7")


## Output nodes have a special titlebar color.
func get_title_color() -> Color:
	if Engine.is_editor_hint():
		# gdlint:ignore = duplicated-load
		var gaea_editor_settings: GDScript = load("uid://duu3vekk7pxwk")
		return gaea_editor_settings.get_configured_output_color()
	return super()


func _get_output_ports_list() -> Array[StringName]:
	return []


func _get_output_port_type(_output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.NULL


func _get_data(_output_port: StringName, _pouch: GaeaGenerationPouch) -> Variant:
	return null
