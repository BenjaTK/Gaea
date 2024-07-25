class_name AdvancedModifierRule
extends Resource
## Abstract class for rules used for [AdvancedModifier2D] and [AdvancedModifier3D].


enum Type {
	NORMAL, ## Only place the tile if the target cell follows this rule.
	INVERT ## Only place the tile if the target cell doesn't follow this rule.
}

@export var type: Type = Type.NORMAL


func passes_rule(grid: GaeaGrid, cell) -> bool:
	return false
