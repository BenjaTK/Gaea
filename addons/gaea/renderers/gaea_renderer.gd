@tool
@icon("gaea_renderer.svg")
class_name GaeaRenderer
extends Node
## Base class for Gaea's generator renderers.
##
## Takes a generator's grid and draws/renders it.

## Emitted when the whole grid is rendered.
signal grid_rendered

## The generator to be rendered.[br]
## [b]Note:[/b] If you're chaining generators together using [param next_pass],
## this has to be set to the last generator in the chain.
@export var generator: GaeaGenerator:
	set(value):
		generator = value

		_disconnect_signals()

		if is_instance_valid(generator):
			if not generator.is_node_ready() and not is_node_ready():
				return

			_connect_signals()
		update_configuration_warnings()


func _ready() -> void:
	if is_instance_valid(generator):
		_connect_signals()


## Draws the whole grid.
func _draw() -> void:
	push_warning("_draw at %s not overriden" % name)


func _connect_signals() -> void:
	generator.grid_updated.connect(_draw)


func _disconnect_signals() -> void:
	for s in get_incoming_connections():
		s.signal.disconnect(s.callable)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray

	if not is_instance_valid(generator):
		warnings.append("Needs a GaeaGenerator to work.")

	return warnings
