@tool
class_name GaeaRenderer
extends Node
## Base class for Gaea's generator renderers.

@export var generator: GaeaGenerator :
	set(value):
		generator = value

		_disconnect_signals()

		if not value == null:
			if not generator.is_node_ready() and not is_node_ready():
				return

			_connect_signals()
		update_configuration_warnings()


func _ready() -> void:
	_connect_signals()


func _connect_signals() -> void:
	generator.grid_updated.connect(_draw)

	if generator.has_signal("chunk_updated"):
		generator.chunk_updated.connect(_draw_chunk)


func _disconnect_signals() -> void:
	for s in get_incoming_connections():
		s.signal.disconnect(s.callable)


func _draw_chunk(chunk_position: Vector2i) -> void:
	print(chunk_position)
	_draw_area(Rect2i(
			chunk_position * generator.chunk_size,
			Vector2i(generator.chunk_size, generator.chunk_size))
		)


func _draw() -> void:
	_draw_area(generator.get_area_from_grid(generator.grid))


func _draw_area(area: Rect2i) -> void:
	pass


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray

	if not is_instance_valid(generator):
		warnings.append("Needs a GaeaGenerator to work.")

	return warnings
