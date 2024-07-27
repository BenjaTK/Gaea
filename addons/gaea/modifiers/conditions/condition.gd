@icon("condition.svg")
class_name AdvancedModifierCondition
extends Resource
## Abstract class for conditions used for [AdvancedModifier2D] and [AdvancedModifier3D].


enum Mode {
	NORMAL, ## Only place the tile if the target cell follows this condition.
	INVERT ## Only place the tile if the target cell doesn't follow this condition.
}

## Can be normal or inverted.
@export var mode: Mode = Mode.NORMAL


func passes_condition(grid: GaeaGrid, cell) -> bool:
	return false
