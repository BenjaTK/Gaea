@tool
class_name ChanceRule
extends AdvancedModifierRule


@export_range(0.0, 100.0, 0.1, "suffix:%") var chance: float = 100.0


func passes_condition(grid: GaeaGrid, cell) -> bool:
	return randf_range(0, 100) < chance
