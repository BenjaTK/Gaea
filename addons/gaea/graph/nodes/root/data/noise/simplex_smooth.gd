@tool
extends GaeaNodeResource
class_name GaeaNodeSimplexSmooth
## Creates a grid of values from [code]0.0[/code] to [code]1.0[/code] based on a SimplexSmooth noise texture.
##
## Generic class for both the 2D and 3D version of this node.


enum Type {TYPE_2D, TYPE_3D}

## Whether it uses the [method Noise.get_noise_2d] or [method Noise.get_noise_3d].
var type = Type.TYPE_2D


func _get_title() -> String:
	return "SimplexSmooth"


func _get_description() -> String:
	return "Creates a grid of values from [code]0[/bg][/c] to [code]1[/bg][/c] based on a SimplexSmooth noise texture.\n[b]Ignores the z axis.[/b]"


func _get_arguments_list() -> Array[StringName]:
	return [&"frequency", &"lacunarity", &"octaves"]


func _get_argument_type(arg_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.INT if arg_name == &"octaves" else GaeaValue.Type.FLOAT


func _get_argument_default_value(arg_name: StringName) -> Variant:
	match arg_name:
		&"frequency": return 0.01
		&"lacunarity": return 2.0
		&"octaves": return 5
	return super(arg_name)


func _get_output_ports_list() -> Array[StringName]:
	return [&"data"]


func _get_output_port_type(output_name: StringName) -> GaeaValue.Type:
	return GaeaValue.Type.DATA


func _get_data(output_port: StringName, area: AABB, generator_data: GaeaData) -> Dictionary:
	_log_data(output_port, generator_data)

	var _noise: FastNoiseLite = FastNoiseLite.new()
	_noise.seed = generator_data.generator.seed + salt

	_noise.frequency = _get_arg(&"frequency", area, generator_data)
	_noise.fractal_octaves = _get_arg(&"octaves", area, generator_data)
	_noise.fractal_lacunarity = _get_arg(&"lacunarity", area, generator_data)
	var dictionary: Dictionary[Vector3i, float]
	for x in _get_axis_range(Axis.X, area):
		for y in _get_axis_range(Axis.Y, area):
			for z in _get_axis_range(Axis.Z, area):
				dictionary[Vector3i(x, y, z)] = (_get_noise_value(Vector3i(x, y, z), _noise) + 1.0) / 2.0
	return dictionary


func _get_noise_value(cell: Vector3i, noise: FastNoiseLite) -> float:
	if type == 0:
		return noise.get_noise_2d(cell.x, cell.y)
	else:
		return noise.get_noise_3d(cell.x, cell.y, cell.z)
