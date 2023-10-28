class_name Modifier
extends Resource
##@tutorial(Modifiers): https://benjatk.github.io/Gaea/#/modifiers


enum FilterType {
	NONE, ## Won't apply any filtering.
	BLACKLIST, ## The modifier won't affect the [TileInfo]s whose [param id] can be found in [param filter_ids].
	WHITELIST ## The modifier will ONLY affect the [TileInfo]s whose [param id] can be found in [param filter_ids].
}

@export_group("Filters", "filter_")
## [i]Note: Some modifiers don't support filtering.[/i]
@export var filter_type: FilterType = FilterType.NONE
## An array containing ids that will be used
## to filter the modifier.
@export var filter_ids: Array[String] = []


func apply(grid: GaeaGrid, generator: GaeaGenerator) -> void:
	pass


## Returns true if the [param tile_info] can be modified according
## to the filters.
func _passes_filter(tile_info: TileInfo) -> bool:
	if tile_info == null:
		return false

	match filter_type:
		FilterType.BLACKLIST:
			return not filter_ids.has(tile_info.id)
		FilterType.WHITELIST:
			return filter_ids.has(tile_info.id)
		_:
			return true
