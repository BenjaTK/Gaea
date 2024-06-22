@tool
@icon("walker_generator.svg")
class_name WalkerGenerator
extends GaeaGenerator2D
## Generates a world using Walkers, which move in random direction and place tiles where they walk.
## @tutorial(Generators): https://benjatk.github.io/Gaea/#/generators/
## @tutorial(WalkerGenerator): https://benjatk.github.io/Gaea/#/generators/walker
## @tutorial(Gaea's Getting Started tutorial): https://benjatk.github.io/Gaea/#/tutorials/getting_started


class Walker:
	var pos = Vector2.ZERO
	var dir = Vector2.ZERO


@export var settings: WalkerGeneratorSettings
@export var starting_tile := Vector2.ZERO

var _walkers: Array[Walker]
var _walked_tiles: PackedVector2Array


func generate(starting_grid: GaeaGrid = null) -> void:
	if Engine.is_editor_hint() and not editor_preview:
		push_warning("%s: Editor Preview is not enabled so nothing happened!" % name)
		return

	if not settings:
		push_error("%s doesn't have a settings resource" % name)
		return

	generation_started.emit()

	var _time_now: int = Time.get_ticks_msec()

	if starting_grid == null:
		erase()
	else:
		grid = starting_grid

	_add_walker(starting_tile)
	_generate_floor()
	_apply_modifiers(settings.modifiers)

	if is_instance_valid(next_pass):
		next_pass.generate(grid)
		return

	var _time_elapsed: int = Time.get_ticks_msec() - _time_now
	if OS.is_debug_build():
		print("%s: Generating took %s seconds" % [name, float(_time_elapsed) / 1000])

	grid_updated.emit()
	generation_finished.emit()


func erase() -> void:
	super.erase()
	_walked_tiles.clear()
	_walkers.clear()


### Steps ###


func _add_walker(pos) -> void:
	var walker = Walker.new()
	walker.dir = _random_dir()
	walker.pos = pos

	_walkers.append(walker)


func _generate_floor() -> void:
	var iterations = 0

	while iterations < 100000:
		for walker in _walkers:
			_move_walker(walker)

		if settings.fullness_check == settings.FullnessCheck.TILE_AMOUNT:
			if _walked_tiles.size() >= settings.max_tiles:
				break
		elif settings.fullness_check == settings.FullnessCheck.PERCENTAGE:
			var _world_size_max: int = settings.world_size.x * settings.world_size.y
			if float(_walked_tiles.size()) / _world_size_max >= settings.fullness_percentage:
				break

		iterations += 1

	for tile in _walked_tiles:
		grid.set_value(tile, settings.tile)

	_walkers.clear()
	_walked_tiles.clear()


func _move_walker(walker: Walker) -> void:
	if randf() <= settings.destroy_walker_chance and _walkers.size() > 1:
		_walkers.erase(walker)
		return

	if not _walked_tiles.has(walker.pos):
		_walked_tiles.append(walker.pos)

	if randf() <= settings.new_dir_chance:
		var random_rotation = _get_random_rotation()
		walker.dir = round(walker.dir.rotated(random_rotation))

	if randf() <= settings.new_walker_chance and _walkers.size() < settings.max_walkers:
		_add_walker(walker.pos)

	for room in settings.room_chances:
		if randf() <= settings.room_chances[room]:
			var room_tiles = _get_square_room(walker.pos, room)
			for pos in room_tiles:
				if not _walked_tiles.has(pos):
					_walked_tiles.append(pos)

	walker.pos += walker.dir
	if settings.constrain_world_size:
		walker.pos = _constrain_to_world_size(walker.pos)


### Utilities ###


func _random_dir() -> Vector2:
	match randi_range(0, 3):
		0:
			return Vector2.RIGHT
		1:
			return Vector2.LEFT
		2:
			return Vector2.UP
		_:
			return Vector2.DOWN


func _get_random_rotation() -> float:
	match randi_range(0, 2):
		0:
			return deg_to_rad(90)
		1:
			return deg_to_rad(-90)
		_:
			return deg_to_rad(180)


func _get_square_room(starting_pos: Vector2, size: Vector2) -> PackedVector2Array:
	var tiles: PackedVector2Array = []
	var x_offset = floor(size.x / 2)
	var y_offset = floor(size.y / 2)
	for x in size.x:
		for y in size.y:
			var coords = starting_pos + Vector2(x - x_offset, y - y_offset)
			tiles.append(coords)
	return tiles


func _constrain_to_world_size(pos: Vector2) -> Vector2:
	pos.x = clamp(
		pos.x, (starting_tile.x - settings.world_size.x / 2) + 1, (starting_tile.x + settings.world_size.x / 2) - 2
	)
	pos.y = clamp(
		pos.y, (starting_tile.y - settings.world_size.y / 2) + 1, (starting_tile.y + settings.world_size.y / 2) - 2
	)
	return pos


### Editor ###


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray

	if not settings:
		warnings.append("Needs WalkerGeneratorSettings to work.")

	return warnings
