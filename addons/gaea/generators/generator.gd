@tool
@icon("generator.svg")
class_name GaeaGenerator
extends Node
## Base class for the Gaea addon's procedural generator.
## @tutorial(Generators): https://benjatk.github.io/Gaea/#/generators/


## Emitted when any changes to the [param grid] are made.
signal grid_updated
## Emitted when [method generate] successfully starts.
signal generation_started
## Emitted when [method generate] successfully finished.
signal generation_finished


## If [code]true[/code], allows for generating a preview of the generation
## in the editor. Useful for debugging.
@export var editor_preview: bool = false :
	set(value):
		editor_preview = value
		if value == false:
			erase()
## If [code]true[/code] regenerates on [code]_ready()[/code].
## If [code]false[/code] and a world was generated in the editor,
## it will be kept.
@export var generate_on_ready: bool = true
@export var random_seed: bool = true :
	set(value):
		random_seed = value
		notify_property_list_changed()
@export var seed: int = 0 : set = set_seed, get = get_seed


var grid : GaeaGrid : get = get_grid


func _ready() -> void:
	if random_seed:
		seed = randi()

	generation_started.connect(_on_generation_started)

	if Engine.is_editor_hint():
		return

	# Wait for a process frame, so the Renderer can connect the signals.
	await get_tree().process_frame

	if generate_on_ready:
		generate()


func generate(starting_grid: GaeaGrid = null) -> void:
	push_warning("generate method at %s not overriden" % name)


func erase() -> void:
	if grid != null:
		grid.clear()
		grid_updated.emit()


func get_grid() -> GaeaGrid:
	return grid


func set_seed(value: int) -> void:
	seed = value


func get_seed() -> int:
	return seed


### Modifiers ###

func _apply_modifiers(modifiers) -> void:
	for modifier in modifiers:
		if not (modifier is Modifier):
			continue

		modifier.apply(grid, self)


func _on_generation_started() -> void:
	if random_seed:
		seed = randi()

	seed(seed)


func _validate_property(property: Dictionary) -> void:
	if property.name == "seed" and random_seed:
		property.usage = PROPERTY_USAGE_NONE
