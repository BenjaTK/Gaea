@tool
class_name NoiseCondition
extends AdvancedModifierCondition


@export var noise: FastNoiseLite
## Forces 3D noise to be 2D instead. Makes it more consistent with the preview and not be affected by elevation.
@export var force_2d: bool = false
@export_group("Thresholds")
## The minimum threshold
@export_range(-1.0, 1.0) var min: float = -1.0:
	set(value):
		min = value
		if min > max:
			max = min
		emit_changed()
## The maximum threshold
@export_range(-1.0, 1.0) var max: float = 1.0:
	set(value):
		max = value
		if max < min:
			min = max
		emit_changed()


func is_condition_met(grid: GaeaGrid, cell) -> bool:
	var value: float = 0.0
	if cell is Vector2i:
		value = noise.get_noise_2dv(cell)
	elif cell is Vector3i:
		if force_2d:
			value = noise.get_noise_2d(cell.x, cell.z)
		else:
			value = noise.get_noise_3dv(cell)

	return value >= min and value <= max
