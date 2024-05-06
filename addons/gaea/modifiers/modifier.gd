@tool
class_name Modifier
extends Resource
##@tutorial(Modifiers): https://benjatk.github.io/Gaea/#/modifiers


enum FilterType {
	NONE, ## Won't apply any filtering.
	BLACKLIST, ## The modifier won't affect the [TileInfo]s in any of the [param check_for_in_layers] whose [param id] can be found in [param filter_ids].
	WHITELIST ## The modifier will ONLY affect the [TileInfo]s in any of the [param check_for_in_layers] whose [param id] can be found in [param filter_ids].
}

@export_group("")
@export var enabled: bool = true
@export var affected_layers: Array[int] = [0]
@export_group("Filters", "filter_")
## [i]Note: Some modifiers don't support filtering.[/i]
@export var filter_type: FilterType = FilterType.NONE :
	set(value):
		filter_type = value
		notify_property_list_changed()
## All layers the filter should check for to find the ids in [param check_for_ids].[br][br]
## [b]E.g:[/b] If a NoisePainter wants to place a tile in (0, 0), and the filter type is WHITELIST, it checks that
## there's at least one tile in (0, 0) in any of the layers whose id can be found in [param check_for_ids].
@export var filter_check_for_in_layers: Array[int] = []
## An array containing ids that will be used
## to filter the modifier.
@export var filter_check_for_ids: Array[String] = []


func apply(grid: GaeaGrid, generator: GaeaGenerator) -> void:
	pass


## Returns true if the [param tile_info] can be modified according
## to the filters.
func _passes_filter(grid: GaeaGrid, cell) -> bool:
	if filter_type == FilterType.NONE:
		return true

	for layer in filter_check_for_in_layers:
		var value = grid.get_value(cell, layer)
		if value is TileInfo and value.id in filter_check_for_ids:
			return filter_type == FilterType.WHITELIST

	return filter_type == FilterType.BLACKLIST


func _validate_property(property: Dictionary) -> void:
	if property.name.begins_with("filter_check") and filter_type == FilterType.NONE:
		property.usage = PROPERTY_USAGE_NONE
