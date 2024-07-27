@tool
@icon("res://addons/gaea/modifiers/2D/advanced_modifier.svg")
class_name AdvancedModifier3D
extends ChunkAwareModifier3D

## All conditions have to be followed by the target cell for the [param tile] to be placed.
## (Unless the condition's mode is [enum AdvancedModifierRule.Mode.INVERT], in which case it's the opposite)
@export var conditions: Array[AdvancedModifierRule]
@export var tile: TileInfo


func _apply_area(area: AABB, grid: GaeaGrid, _generator: GaeaGenerator) -> void:
	if conditions.is_empty():
		return

	seed(_generator.seed + salt)
	for condition in conditions:
		if condition.get("noise") != null and condition.get("noise") is FastNoiseLite:
			condition.noise.seed = _generator.seed + salt

	for x in range(area.position.x, area.end.x + 1):
		for y in range(area.position.y, area.end.y + 1):
			for z in range(area.position.z, area.end.z + 1):
				if not _passes_filter(grid, Vector3i(x, y, z)):
					continue

				var passes: bool = true
				for condition in conditions:
					if condition is AdvancedModifierRule2D:
						continue



					var condition_passed: bool = condition.passes_condition(grid, Vector3i(x, y, z))

					if condition.mode == AdvancedModifierRule.Mode.INVERT:
						condition_passed = not condition_passed

					if not condition_passed:
						passes = false
						break

				if passes:
					grid.set_value(Vector3i(x, y, z), tile)
