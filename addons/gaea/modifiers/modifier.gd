@tool
class_name Modifier
extends Resource
##@tutorial(Modifiers): https://benjatk.github.io/Gaea/#/modifiers

enum FilterType {
	NONE, ## Won't apply any filtering.
	BLACKLIST, ## The modifier won't affect the [TileInfo]s in any of the [param layers] whose [param id] can be found in [param ids].
	WHITELIST, ## The modifier will ONLY affect the [TileInfo]s in any of the [param layers] whose [param id] can be found in [param ids].
	ONLY_EMPTY_CELLS ## The modifier will ONLY affect empty ([code]null[/code]) cells.
}

@export_group("")
@export var enabled: bool = true
@export var affected_layers: Array[int] = [0]

@export_group("Filters")
## Whether or not all filters need to pass. (AND vs OR behaviour)
@export var strict_filters: bool = true
@export var filters: Array[Filter] = []


func apply(grid: GaeaGrid, generator: GaeaGenerator) -> void:
	pass

## Returns true if the [param tile_info] can be modified according
## to the filters. All filters must pass if "Strict Filters" is checked.
func _passes_filter(grid: GaeaGrid, cell) -> bool:
	for filter in filters:
		var passed:bool = filter._passes_filter(grid, cell)
		if passed and not strict_filters:
			return true
		elif not passed and strict_filters:
			return false
	return strict_filters

func _validate_property(property: Dictionary) -> void:
	pass
