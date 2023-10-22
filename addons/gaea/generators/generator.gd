@tool
@icon("generator.svg")
class_name GaeaGenerator
extends Node
## Base class for the Gaea addon's procedural generator.
## @tutorial(Generators): https://benjatk.github.io/Gaea/#/generators/


signal grid_updated
signal generation_finished


## If [code]true[/code], allows for generating a preview of the generation
## in the editor. Useful for debugging.
@export var preview: bool = false :
	set(value):
		preview = value
		if value == false:
			erase()
## If [code]true[/code] regenerates on [code]_ready()[/code].
## If [code]false[/code] and a world was generated in the editor,
## it will be kept.
@export var generate_on_ready: bool = true

var grid : Dictionary


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	## Wait for a process frame, so the Renderer can connect the signals.
	await get_tree().process_frame

	if generate_on_ready:
		generate()


func generate() -> void:
	push_warning("generate method at %s not overriden" % get_path())


func erase() -> void:
	grid.clear()
	grid_updated.emit()


### Modifiers ###


func _apply_modifiers(modifiers) -> void:
	for modifier in modifiers:
		if not (modifier is Modifier):
			continue

		grid = modifier.apply(grid, self)
