@tool
class_name RandomTileInfo
extends TileInfo
## When used in a grid, sets its cell's value to a random tile from [param tiles].

const WEIGHT_PREFIX = "weight_"

@export var tiles: Array[TileInfo]:
	set(value):
		tiles = value
		_update_weights()
		notify_property_list_changed()
## If [code]true[/code], tiles will have weights attached to them.
## Tiles with higher weights are more likely to get chosen.
@export var use_weights: bool = true:
	set(value):
		use_weights = value
		notify_property_list_changed()
@export_group("Weights", "weight_")

var _weights: Dictionary


## Returns a random [TileInfo] from [param tiles].
func get_random() -> TileInfo:
	if tiles.is_empty():
		return null

	if not use_weights:
		return tiles.pick_random()

	var total_weight := 0.0

	for weight in _weights.values():
		total_weight += weight

	var rand := randf_range(0.0, total_weight)
	var running_total := 0.0
	for object in _weights.keys():
		running_total += _weights[object]
		if rand <= running_total:
			return object

	return null


func _update_weights() -> void:
	var new_weights: Dictionary
	for resource in tiles:
		if _weights.has(resource):
			new_weights[resource] = _weights[resource]
		else:
			new_weights[resource] = 1.0
	_weights = new_weights
	notify_property_list_changed()


func _get_property_list() -> Array[Dictionary]:
	var property_list: Array[Dictionary] = []

	if use_weights:
		for idx in _weights.size():
			property_list.append(
				{
					"name": WEIGHT_PREFIX + str(idx),
					"type": TYPE_FLOAT,
					"usage": PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_EDITOR,
					"hint": PROPERTY_HINT_RANGE,
					"hint_string": "0.01,100"
				}
			)

	return property_list


func _set(property: StringName, value: Variant) -> bool:
	if property.begins_with(WEIGHT_PREFIX):
		var idx = int(property.trim_prefix(WEIGHT_PREFIX))
		_weights[tiles[idx]] = value
		return true

	return false


func _get(property: StringName) -> Variant:
	if property.begins_with(WEIGHT_PREFIX):
		var idx = int(property.trim_prefix(WEIGHT_PREFIX))
		return _weights[tiles[idx]]

	return null
