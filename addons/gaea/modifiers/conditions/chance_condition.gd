@tool
class_name ChanceCondition
extends AdvancedModifierCondition


## This condition is only met [param chance]% of times.
@export_range(0.0, 100.0, 0.1, "suffix:%") var chance: float = 100.0


func is_condition_met(grid: GaeaGrid, cell) -> bool:
	return randf_range(0, 100) < chance
