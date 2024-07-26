@tool
class_name OffsetRule3D
extends AdvancedModifierRule3D
## This rule is only met when a tile from [param ids] is found in an [param offset] from the target cell.


enum Offsets {
	BELOW, ## Place the [AdvancedModifier3D]'s tile only if it has any tiles from [param ids] below.
	ABOVE, ## Place the [AdvancedModifier3D]'s tile only if it has any tiles from [param ids] above.
	LEFT, ## Place the [AdvancedModifier3D]'s tile only if it has any tiles from [param ids] to the left.
	RIGHT, ## Place the [AdvancedModifier3D]'s tile only if it has any tiles from [param ids] to the right.
	FRONT, ## Place the [AdvancedModifier3D]'s tile only if it has any tiles from [param ids] in front ([code]Vector3i(0, 0, -1)[/code])
	BACK, ## Place the [AdvancedModifier3D]'s tile only if it has any tiles from [param ids] at its back ([code]Vector3i(0, 0, 1)[/code])
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
		var value = grid.get_value(cell + _offset, layer)
		if value is TileInfo and value.id in ids:
			return true
	return false


func _validate_property(property: Dictionary) -> void:
	if property.name == "custom_offset" and offset != Offsets.CUSTOM:
		property.usage = PROPERTY_USAGE_NONE
