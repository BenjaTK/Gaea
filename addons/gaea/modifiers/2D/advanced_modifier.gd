@tool
class_name AdvancedModifier2D
extends ChunkAwareModifier2D

## All rules have to be followed by the target cell for the [param tile] to be placed.
## (Unless the rule's mode is [enum AdvancedModifierRule.Mode.INVERT], in which case it's the opposite)
@export var rules: Array[AdvancedModifierRule]
@export var tile: TileInfo


func _apply_area(area: Rect2i, grid: GaeaGrid, _generator: GaeaGenerator) -> void:
	seed(_generator.seed + salt)
	for rule in rules:
		if rule.get("noise") != null and rule.get("noise") is FastNoiseLite:
			rule.noise.seed = _generator.seed + salt

	for x in range(area.position.x, area.end.x + 1):
		for y in range(area.position.y, area.end.y + 1):
			if not _passes_filter(grid, Vector2i(x, y)):
				continue

			var passes: bool = true
			for rule in rules:
				if rule is AdvancedModifierRule3D:
					continue

				var rule_passed: bool = rule.passes_rule(grid, Vector2i(x, y))
				if rule.mode == AdvancedModifierRule.Mode.INVERT:
					rule_passed = not rule_passed

				if not rule_passed:
					passes = false
					break

			if passes:
				grid.set_value(Vector2i(x, y), tile)
