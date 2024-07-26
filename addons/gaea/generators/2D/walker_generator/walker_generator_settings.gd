@tool
class_name WalkerGeneratorSettings
extends GeneratorSettings2D
## Settings for [WalkerGenerator]

enum FullnessCheck { TILE_AMOUNT, PERCENTAGE }  ## Restricts the generation to a predetermined amount of floor tiles.  ## Restricts the generation to a percentage of the [param world size]. Automatically sets Constrain World Size to true if set to this mode.

## Info for the tile that will be placed. Has information about
## it's position in the TileSet.
@export var tile: TileInfo
## The mode of check to stop the generation.
@export var fullness_check: FullnessCheck:
	set(value):
		fullness_check = value
		if fullness_check == FullnessCheck.PERCENTAGE:
			constrain_world_size = true
		notify_property_list_changed()
## Maximum amount of floor tiles.
@export var max_tiles := 150
## Maximum percentage of the [param world_size] to be filled with floors.
@export var fullness_percentage := 0.2
## Can't be [code]false[/code] if [param Fullness Check] is on [b]Percentage[/b] mode.
@export var constrain_world_size: bool = false:
	set(value):
		if fullness_check == FullnessCheck.PERCENTAGE and value == false:
			return
		constrain_world_size = value
		notify_property_list_changed()
@export var world_size := Vector2i(30, 30)
## Modifiers can change stuff about your generation. They can be used to
## generate walls, smooth out terrain, etc.
@export_group("Walkers")
## The amount of walkers that can be active at the same time.[br]
## [b]Walkers[/b] move in random directions and place floor tiles where they walk.
## They are the foundation of this mode of generation.
@export var max_walkers = 5
## The chance for a walker to change direction. Lower chances mean
## tighter hallways.
@export var new_dir_chance = 0.5
## The chance for a walker to spawn a new walker.
@export var new_walker_chance = 0.05
## The chance for a walker to be destroyed (won't happen
## if there's only one walker in the scene)
@export var destroy_walker_chance = 0.05
## The chances for walkers to place tiles bigger than 1x1.[br]You can
## add new sizes or remove them if you don't want any. They can help
## build large open areas.[br]
## [b]Note:[/b] Chances are between [code]0-1[/code]
@export var room_chances = {Vector2i(2, 2): 0.5, Vector2i(3, 3): 0.1}


func _validate_property(property: Dictionary) -> void:
	match fullness_check:
		FullnessCheck.TILE_AMOUNT:
			if property.name == "fullness_percentage":
				property.usage = PROPERTY_USAGE_NONE
		FullnessCheck.PERCENTAGE:
			if property.name == "max_tiles":
				property.usage = PROPERTY_USAGE_NONE
	if not constrain_world_size and property.name == "world_size":
		property.usage = PROPERTY_USAGE_NONE
