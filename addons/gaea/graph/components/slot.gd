@tool
extends HBoxContainer

enum SlotTypes {
	VALUE_DATA, TILE_DATA, TILE_INFO, VECTOR2, NUMBER
}


@export_group("Left", "left")
@export var left_enabled: bool = true
@export var left_type: SlotTypes
@export var left_label: String = ""
@export_group("Right", "right")
@export var right_enabled: bool = true
@export var right_type: SlotTypes
@export var right_label: String = ""

var from_node: GraphNode

@onready var _left_label: Label = $LeftLabel
@onready var _right_label: Label = $RightLabel


func _ready() -> void:
	var _graph_node: Node = get_parent()
	if _graph_node is not GraphNode:
		return

	if not _graph_node.is_node_ready():
		await _graph_node.ready
	var parent: Node = get_parent()
	var idx: int = get_index()
	if parent != owner and parent.get_parent() == owner:
		idx = parent.get_index()

	_graph_node.set_slot(
		idx,
		left_enabled, left_type, get_color_from_type(left_type),
		right_enabled, right_type, get_color_from_type(right_type),
	)

	if left_enabled:
		_left_label.text = left_label
	if right_enabled:
		_right_label.text = right_label


func get_color_from_type(type: SlotTypes) -> Color:
	match type:
		SlotTypes.VALUE_DATA:
			return Color("9c999e")
		SlotTypes.TILE_DATA:
			return Color("45ffa2")
		SlotTypes.TILE_INFO:
			return Color("ff4545")
		SlotTypes.VECTOR2:
			return Color("a579ff")
		SlotTypes.NUMBER:
			return Color.LIGHT_GRAY
	return Color.WHITE
