@tool
class_name AdvancedModifier3D
extends ChunkAwareModifier3D

## All rules have to be followed by the target cell for the [param tile] to be placed.
## (Unless the rule's type is [code]Invert[/code], in which case it's the opposite)
@export var rules: Array[AdvancedModifierRule]
@export var tile: TileInfo


func _apply_area(area: AABB, grid: GaeaGrid, _generator: GaeaGenerator) -> void:
	for x in range(area.position.x, area.end.x + 1):
		for y in range(area.position.y, area.end.y + 1):
			for z in range(area.position.z, area.end.z + 1):
				if not _passes_filter(grid, Vector3i(x, y, z)):
					continue

				seed(_generator.seed + salt + x + y + z)

				var passes: bool = true
				for rule in rules:
					if rule is AdvancedModifierRule2D:
						continue

					var rule_passed: bool = rule.passes_rule(grid, Vector3i(x, y, z))
					if rule.type == AdvancedModifierRule.Type.INVERT:
						rule_passed = not rule_passed

					if not rule_passed:
						passes = false
						break

				if passes:
					grid.set_value(Vector3i(x, y, z), tile)
