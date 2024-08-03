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
@export_group("Filtering", "filter_")
## [i]Note: Some modifiers don't support filtering.[/i]
@export var filter_type: FilterType = FilterType.NONE:
	set(value):
		filter_type = value
		notify_property_list_changed()
## An array containing ids that will be used
## to filter the modifier.
@export var filter_ids: Array[String] = []
## All layers the filter should check in for the other filtering options.
## [b]E.g:[/b] If a NoisePainter wants to place a tile in (0, 0), and the filter type is WHITELIST, it checks that
## there's at least one tile in (0, 0) in any of the layers whose id can be found in [param check_for_ids].
@export var filter_layers: Array[int] = []


func apply(grid: GaeaGrid, generator: GaeaGenerator) -> void:
	pass


## Returns true if the [param tile_info] can be modified according
## to the filters.
func _passes_filter(grid: GaeaGrid, cell) -> bool:
	if filter_type == FilterType.NONE:
		return true

	if filter_type == FilterType.ONLY_EMPTY_CELLS:
		for layer in grid.get_layer_count():
			if grid.get_value(cell, layer) != null:
				return false
		return true

	var layers: Array = filter_layers
	if layers.is_empty():
		layers = grid.get_grid().keys()

	for layer in layers:
		var value = grid.get_value(cell, layer)
		if value is TileInfo and value.id in filter_ids:
			return filter_type == FilterType.WHITELIST

	return filter_type == FilterType.BLACKLIST


func _validate_property(property: Dictionary) -> void:
	if (property.name == "filter_ids" or property.name == "filter_layers") and filter_type == FilterType.NONE:
		property.usage = PROPERTY_USAGE_NONE
	elif property.name == "filter_ids" and filter_type == FilterType.ONLY_EMPTY_CELLS:
		property.usage = PROPERTY_USAGE_NONE
