@tool
@icon("walker_generator.svg")
class_name WalkerGenerator extends GaeaGenerator


class Walker:
	var pos = Vector2.ZERO
	var dir = Vector2.ZERO
	var stepsSinceDirChange = 0

signal generation_finished


## If [code]true[/code], allows for generating a preview of the generation
## in the editor. Useful for checking parameters.
@export var preview: bool = false :
	set(value):
		preview = value
		if value == false:
			remove()

## [WalkerGeneratorParameters] that will affect the generation.
@export var parameters: WalkerGeneratorParameters
@export var startingTile := Vector2.ZERO

var walkers : Array[Walker]
var walkedTiles : Array[Vector2]


func generate() -> void:
	if Engine.is_editor_hint() and not preview:
		return

	if not parameters or not is_instance_valid(tileMap):
		return

	_setup()
	_generate_floor()
	_apply_modifiers()
	_place_tiles()

	generation_finished.emit()


func _setup() -> void:
	remove()

	_add_walker(startingTile)


func remove() -> void:
	super.remove()
	walkedTiles.clear()
	walkers.clear()


### Steps ###


func _add_walker(pos) -> void:
	var walker = Walker.new()
	walker.dir = _random_dir()
	walker.pos = pos

	walkers.append(walker)


func _generate_floor() -> void:
	var iterations = 0

	while iterations < 100000:
		for walker in walkers:
			_move_walker(walker)

		if parameters.fullnessCheck == parameters.FullnessCheck.TILE_AMOUNT:
			if walkedTiles.size() >= parameters.maxTiles:
				break
		elif parameters.fullnessCheck == parameters.FullnessCheck.PERCENTAGE:
			if walkedTiles.size() / (parameters.worldSize.x * parameters.worldSize.y) >= parameters.fullnessPercentage:
				break

		iterations += 1

	for tile in walkedTiles:
		grid[tile] = Tiles.FLOOR

	walkers.clear()
	walkedTiles.clear()


func _move_walker(walker: Walker) -> void:
	if randf() <= parameters.destroyWalkerChance && walkers.size() > 1:
		walkers.erase(walker)
		return

	if not walkedTiles.has(walker.pos):
		walkedTiles.append(walker.pos)

	if randf() <= parameters.newDirChance:
		var randomRotation = _get_random_rotation()
		walker.dir = round(walker.dir.rotated(randomRotation))

	if randf() <= parameters.newWalkerChance and walkers.size() < parameters.maxWalkers:
		_add_walker(walker.pos)

	for bigRoom in parameters.roomChances:
		if randf() <= parameters.roomChances[bigRoom]:
			var room = _get_square_room(walker.pos, bigRoom)
			for pos in room:
				if not walkedTiles.has(pos):
					walkedTiles.append(pos)

	walker.pos += walker.dir
	if parameters.constrainWorldSize:
		walker.pos = _constrain_to_world_size(walker.pos)


func _apply_modifiers() -> void:
	for modifier in parameters.modifiers:
		if not (modifier is Modifier):
			continue

		if not is_instance_valid(modifier):
			modifier = load(modifier.resource_path)

		grid = modifier.apply(grid)


### Utilities ###


func _random_dir() -> Vector2:
	match randi_range(0, 3):
		0: return Vector2.RIGHT
		1: return Vector2.LEFT
		2: return Vector2.UP
		_: return Vector2.DOWN


func _get_random_rotation() -> float:
	match randi_range(0, 2):
		0: return deg_to_rad(90)
		1: return deg_to_rad(-90)
		_: return deg_to_rad(180)


func _get_square_room(startingPos: Vector2, size: Vector2) -> Array:
	var tiles : Array[Vector2] = []
	var xOffset = floor(size.x / 2)
	var yOffset = floor(size.y / 2)
	for x in size.x:
		for y in size.y:
			var coords = startingPos + Vector2(x - xOffset, y - yOffset)
			tiles.append(coords)
	return tiles


func _constrain_to_world_size(pos: Vector2) -> Vector2:
	pos.x = clamp(pos.x,
				(startingTile.x - parameters.worldSize.x / 2) + 1,
				(startingTile.x + parameters.worldSize.x / 2) - 2)
	pos.y = clamp(pos.y,
				(startingTile.y - parameters.worldSize.y / 2) + 1,
				(startingTile.y + parameters.worldSize.y / 2) - 2)
	return pos

### Editor ###


func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray

	warnings.append_array(super._get_configuration_warnings())

	if not parameters:
		warnings.append("Needs WalkerGeneratorParameters to work.")

	return warnings
