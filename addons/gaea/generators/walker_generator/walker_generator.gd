@tool
@icon("walker_generator.svg")
class_name WalkerGenerator extends GaeaGenerator
## Generates a world using Walkers, which move in random direction and place tiles where they walk.


class Walker:
	var pos = Vector2.ZERO
	var dir = Vector2.ZERO
	var stepsSinceDirChange = 0

@export var settings: WalkerGeneratorSettings
@export var startingTile := Vector2.ZERO

var walkers : Array[Walker]
var walkedTiles : Array[Vector2]


func generate() -> void:
	if Engine.is_editor_hint() and not preview:
		return

	super.generate()

	if not settings:
		push_error("%s doesn't have a settings resource" % name)
		return

	_setup()
	_generate_floor()
	_apply_modifiers(settings.modifiers)
	_draw_tiles()

	generation_finished.emit()


func _setup() -> void:
	erase(clearTilemapOnGeneration)

	_add_walker(startingTile)


func erase(clearTilemap := true) -> void:
	super.erase(clearTilemap)
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

		if settings.fullnessCheck == settings.FullnessCheck.TILE_AMOUNT:
			if walkedTiles.size() >= settings.maxTiles:
				break
		elif settings.fullnessCheck == settings.FullnessCheck.PERCENTAGE:
			if walkedTiles.size() / (settings.worldSize.x * settings.worldSize.y) >= settings.fullnessPercentage:
				break

		iterations += 1

	for tile in walkedTiles:
		grid[tile] = defaultTileInfo

	walkers.clear()
	walkedTiles.clear()


func _move_walker(walker: Walker) -> void:
	if randf() <= settings.destroyWalkerChance && walkers.size() > 1:
		walkers.erase(walker)
		return

	if not walkedTiles.has(walker.pos):
		walkedTiles.append(walker.pos)

	if randf() <= settings.newDirChance:
		var randomRotation = _get_random_rotation()
		walker.dir = round(walker.dir.rotated(randomRotation))

	if randf() <= settings.newWalkerChance and walkers.size() < settings.maxWalkers:
		_add_walker(walker.pos)

	for bigRoom in settings.roomChances:
		if randf() <= settings.roomChances[bigRoom]:
			var room = _get_square_room(walker.pos, bigRoom)
			for pos in room:
				if not walkedTiles.has(pos):
					walkedTiles.append(pos)

	walker.pos += walker.dir
	if settings.constrainWorldSize:
		walker.pos = _constrain_to_world_size(walker.pos)


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
				(startingTile.x - settings.worldSize.x / 2) + 1,
				(startingTile.x + settings.worldSize.x / 2) - 2)
	pos.y = clamp(pos.y,
				(startingTile.y - settings.worldSize.y / 2) + 1,
				(startingTile.y + settings.worldSize.y / 2) - 2)
	return pos

### Editor ###


func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray

	warnings.append_array(super._get_configuration_warnings())

	if not settings:
		warnings.append("Needs WalkerGeneratorSettings to work.")

	return warnings
