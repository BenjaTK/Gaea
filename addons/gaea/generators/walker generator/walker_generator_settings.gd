@tool
class_name WalkerGeneratorSettings extends GeneratorSettings
## Settings for [WalkerGenerator]


enum FullnessCheck {
	TILE_AMOUNT, ## Restricts the generation to a predetermined amount of floor tiles.
	PERCENTAGE ## Restricts the generation to a percentage of the [param world size]. Automatically sets Constrain World Size to true if set to this mode.
}

## The type of check to stop the generation.
@export var fullnessCheck: FullnessCheck :
	set(value):
		fullnessCheck = value
		if fullnessCheck == FullnessCheck.PERCENTAGE:
			constrainWorldSize = true
		notify_property_list_changed()
## Modifiers can change stuff about your generation. They can be used to
## generate walls, smooth out terrain, etc.
@export_group("Walkers")
## The amount of walkers that can be active at the same time.[br]
## [b]Walkers[/b] move in random directions and place floor tiles where they walk.
## They are the foundation of this type of generation.
@export var maxWalkers = 5
## The chance for a walker to change direction. Lower chances mean
## tighter hallways.
@export var newDirChance = 0.5
## The chance for a walker to spawn a new walker.
@export var newWalkerChance = 0.05
## The chance for a walker to be destroyed (won't happen
## if there's only one walker in the scene)
@export var destroyWalkerChance = 0.05
## The chances for walkers to place tiles bigger than 1x1.[br]You can
## add new sizes or remove them if you don't want any. They can help
## build large open areas.[br]
## [b]Note:[/b] Chances are between [code]0-1[/code]
@export var roomChances = {
	Vector2(2, 2): 0.5,
	Vector2(3, 3): 0.1
}

## Maximum amount of floor tiles.
var maxTiles := 150
## Maximum percentage of the [param worldSize] to be filled with floors.
var fullnessPercentage := 0.2
## Can't be [code]false[/code] if [param Fullness Check] is on [b]Percentage[/b] mode.
var constrainWorldSize : bool = false :
	set(value):
		if fullnessCheck == FullnessCheck.PERCENTAGE and value == false:
			return
		constrainWorldSize = value
		notify_property_list_changed()
var worldSize := Vector2(30, 30)


func _get_property_list() -> Array[Dictionary]:
	return _get_basic_properties()


func _get_basic_properties() -> Array[Dictionary]:
	var properties : Array[Dictionary]
	match fullnessCheck:
		FullnessCheck.TILE_AMOUNT:
			properties.append({
				"name": "maxTiles",
				"usage": PROPERTY_USAGE_DEFAULT,
				"type": TYPE_INT,
			})
		FullnessCheck.PERCENTAGE:
			properties.append({
				"name": "fullnessPercentage",
				"usage": PROPERTY_USAGE_DEFAULT,
				"type": TYPE_FLOAT,
				"hint": PROPERTY_HINT_RANGE,
				"hint_string": "0.0, 1.0"
			})
	properties.append(
		{
			"name": "constrainWorldSize",
			"usage": PROPERTY_USAGE_DEFAULT,
			"type": TYPE_BOOL
		}
	)

	if constrainWorldSize:
		properties.append({
			"name": "worldSize",
			"usage": PROPERTY_USAGE_DEFAULT,
			"type": TYPE_VECTOR2I,
		})
	return properties
