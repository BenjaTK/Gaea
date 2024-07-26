@tool
class_name OffsetRule3D
extends AdvancedModifierRule3D
## This rule is only met when a tile from [param ids] is found in an [param offset] from the target cell.


enum Offsets {
	BELOW, ## Place the [AdvancedModifier3D]'s tile only BELOW any tiles from [param ids], or it will avoid placing the tile BELOW any tiles from [param ids] if [param mode] is set to [enum AdvancedModifierRule.Mode.INVERT].
	ABOVE, ## Place the [AdvancedModifier3D]'s tile only ABOVE any tiles from [param ids], or it will avoid placing the tile ABOVE any tiles from [param ids] if [param mode] is set to [enum AdvancedModifierRule.Mode.INVERT].
	LEFT, ## Place the [AdvancedModifier3D]'s tile only to the LEFT of any tiles from [param ids], or it will avoid placing the tile to the LEFT of any tiles from [param ids] if [param mode] is set to [enum AdvancedModifierRule.Mode.INVERT].
	RIGHT, ## Place the [AdvancedModifier3D]'s tile only to the RIGHT of any tiles from [param ids], or it will avoid placing the tile to the RIGHT of any tiles from [param ids] if [param mode] is set to [enum AdvancedModifierRule.Mode.INVERT].
	FRONT, ## Place the [AdvancedModifier3D]'s tile only in FRONT of any tiles from [param ids], or it will avoid placing the tile in FRONT of any tiles from [param ids] if [param mode] is set to [enum AdvancedModifierRule.Mode.INVERT].
	BACK, ## Place the [AdvancedModifier3D]'s tile only BEHIND any tiles from [param ids], or it will avoid placing the tile BEHIND any tiles from [param ids] if [param mode] is set to [enum AdvancedModifierRule.Mode.INVERT].
	CUSTOM ## Set your own [Vector3i] for the offset.
	}
## See [enum Offsets].
@export var offset: Offsets :
	set(value):
		offset = value
		notify_property_list_changed()
@export var custom_offset: Vector3i
## The ids of the valid tiles.
@export var ids: Array[StringName]
## The layers in which the modifier will search for tiles that match.
@export var layers: Array[int] = [0]


func passes_rule(grid: GaeaGrid, cell: Vector3i) -> bool:
	var _offset: Vector3i = custom_offset
	match offset:
		Offsets.BELOW:
			_offset = Vector3i.DOWN
		Offsets.ABOVE:
			_offset = Vector3i.UP
		Offsets.LEFT:
			_offset = Vector3i.LEFT
		Offsets.RIGHT:
			_offset = Vector3i.RIGHT
		Offsets.FRONT:
			_offset = Vector3i.FORWARD
		Offsets.BACK:
			_offset = Vector3i.BACK

	for layer in layers:
		var value = grid.get_value(cell - _offset, layer)
		if value is TileInfo and value.id in ids:
			return true
	return false


func _validate_property(property: Dictionary) -> void:
	if property.name == "custom_offset" and offset != Offsets.CUSTOM:
		property.usage = PROPERTY_USAGE_NONE
