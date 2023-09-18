@tool
class_name HeightmapGenerator3D
extends GaeaGenerator3D
## Generates terrain using a heightmap from a noise texture.
## @tutorial(Generators): https://benjatk.github.io/Gaea/#/generators/
## @tutorial(HeightmapGenerator): https://benjatk.github.io/Gaea/#/generators/heightmap

@export var settings: HeightmapGenerator3DSettings


func _ready() -> void:
	if settings.random_noise_seed:
		settings.noise.seed = randi()

	super()


func generate() -> void:
	if Engine.is_editor_hint() and not preview:
		return

	if not settings:
		push_error("%s doesn't have a settings resource" % name)
		return

	if settings.random_noise_seed:
		settings.noise.seed = randi()

	erase()
	_set_grid()
	_apply_modifiers(settings.modifiers)

	grid_updated.emit()


func _set_grid() -> void:
	var max_height: int = 0
	for x in range(settings.world_size.x):
		for z in range(settings.world_size.y):
			max_height = maxi(
				floor(settings.noise.get_noise_2d(x, z) * settings.height_intensity + settings.height_offset),
				max_height
			)

	var area := AABB(
		# starting point
		Vector3i(0, settings.min_height, 0),
		Vector3i(settings.world_size.x, max_height - settings.min_height, settings.world_size.y)
		# size
	)

	_set_grid_area(area)


func _set_grid_area(area: AABB) -> void:
	for x in range(area.position.x, area.end.x):
		for z in range(area.position.z, area.end.z):
			var height = floor(settings.noise.get_noise_2d(x, z) * settings.height_intensity + settings.height_offset)
			for y in range(area.position.y, area.end.y):
				if y < height and y >= settings.min_height:
					grid[Vector3(x, y, z)] = settings.tile
