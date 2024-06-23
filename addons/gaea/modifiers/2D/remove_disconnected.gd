@tool
@icon("remove_disconnected.svg")
class_name RemoveDisconnected
extends Modifier2D
## Uses floodfill to remove areas that aren't connected to [param starting_cell]
## @tutorial(Remove Disconnected Modifier): https://benjatk.github.io/Gaea/#/modifiers?id=-noise-painter

@export var starting_cell := Vector2i.ZERO


func apply(grid: GaeaGrid, generator: GaeaGenerator) -> void:
	var start_cell = starting_cell
	for layer in affected_layers:
		if grid.has_cell(start_cell, layer):
			break

		var closest_cell = _find_closest_cell(start_cell, grid)
		if closest_cell == Vector2i(NAN, NAN):
			push_error("RemoveDisconnected at %s failed, found no start cell." % generator.name)
			return
		push_warning(
			(
				"RemoveDisconnected at %s found no cell at starting cell %s, got closest one %s instead."
				% [generator.name, starting_cell, closest_cell]
			)
		)
		start_cell = closest_cell

	var _temp_grid: GaeaGrid2D = GaeaGrid2D.new()

	var queue: Array[Vector2i]
	queue.append(start_cell)

	while not queue.is_empty():
		var cell = queue.pop_front() as Vector2i
		var found_cell: bool = false
		for layer in affected_layers:
			if not grid.has_cell(cell, layer) or _temp_grid.has_cell(cell, layer):
				continue

			found_cell = true
			_temp_grid.set_value(cell, grid.get_value(cell, layer))

		if not found_cell:
			continue

		queue.append(cell + Vector2i.RIGHT)
		queue.append(cell + Vector2i.UP)
		queue.append(cell + Vector2i.DOWN)
		queue.append(cell + Vector2i.LEFT)

	generator.grid = _temp_grid.clone()
	_temp_grid.unreference()


func _find_closest_cell(to: Vector2i, grid: GaeaGrid) -> Vector2i:
	var queue: Array[Vector2i]
	queue.append(to)
	var checked_cells: Array[Vector2i]

	while not queue.is_empty():
		var cell = queue.pop_front()
		if checked_cells.has(cell):
			continue

		for layer in affected_layers:
			if grid.has_cell(cell, layer):
				return cell

		checked_cells.append(cell)
		queue.append(cell + Vector2i.RIGHT)
		queue.append(cell + Vector2i.UP)
		queue.append(cell + Vector2i.DOWN)
		queue.append(cell + Vector2i.LEFT)

	return Vector2i(NAN, NAN)
