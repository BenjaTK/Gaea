@tool
@icon("remove_disconnected.svg")
class_name RemoveDisconnected
extends Modifier
## Uses floodfill to remove areas that aren't connected to [param starting_tile]
## @tutorial(Remove Disconnected Modifier): https://benjatk.github.io/Gaea/#/modifiers?id=-noise-painter


@export var starting_tile := Vector2.ZERO


func apply(grid: Dictionary, generator: GaeaGenerator) -> Dictionary:
	var start_tile = starting_tile
	if not grid.has(start_tile):
		var closest_tile = _find_closest_tile(start_tile, grid)
		push_warning("RemoveDisconnected at %s found no tile at starting tile %s, got closest one %s instead." % [generator.name, starting_tile, closest_tile])
		start_tile = closest_tile

	var new_grid : Dictionary

	var queue : Array[Vector2]
	queue.append(start_tile)

	while not queue.is_empty():
		var tile = queue.pop_front()
		if not grid.has(tile) or new_grid.has(tile):
			continue

		new_grid[tile] = grid[tile]
		queue.append(tile + Vector2.RIGHT)
		queue.append(tile + Vector2.UP)
		queue.append(tile + Vector2.DOWN)
		queue.append(tile + Vector2.LEFT)

	return new_grid


func _find_closest_tile(to: Vector2, grid: Dictionary) -> Vector2:
	var queue : Array[Vector2]
	queue.append(to)
	var checked_tiles : Array[Vector2]

	while not queue.is_empty():
		var tile = queue.pop_front()
		if checked_tiles.has(tile):
			continue

		if grid.has(tile):
			return tile

		checked_tiles.append(tile)
		queue.append(tile + Vector2.RIGHT)
		queue.append(tile + Vector2.UP)
		queue.append(tile + Vector2.DOWN)
		queue.append(tile + Vector2.LEFT)

	return Vector2.INF
