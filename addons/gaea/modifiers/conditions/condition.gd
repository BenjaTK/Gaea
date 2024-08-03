@icon("condition.svg")
class_name AdvancedModifierCondition
extends Resource
## Abstract class for conditions used for [AdvancedModifier2D] and [AdvancedModifier3D].


enum Mode {
	NORMAL, ## Condition works as normal.
	INVERT ## Inverts the result of the condition, meaning where it would normally be met it isn't and viceversa.
}

## The mode to use.
@export var mode: Mode = Mode.NORMAL


func is_condition_met(grid: GaeaGrid, cell) -> bool:
	return false
