@tool
class_name GridmapGaeaRenderer
extends GaeaRenderer3D

@export var grid_map: GridMap
## Draws only cells with an empty neighbor.
@export var only_draw_visible_cells: bool = true
## Erases the cell when an empty tile is found in all layers. Recommended: [code]true[/code].
@export var erase_empty_tiles: bool = true



func _ready() -> void:
	super()

	if !generator:
		push_error("GridmapGaeaRenderer needs a GaeaGenerator node assigned in its exports.")
		return

	if grid_map.cell_size * grid_map.scale != generator.tile_size:
		push_warning("GridMap's cell size doesn't match with generator's tile size, can cause generation issues.
					The generator's tile size has been set to the GridMap's cell size.")
		generator.tile_size = grid_map.cell_size * grid_map.scale


func _draw_area(area: AABB) -> void:
	for x in range(area.position.x, area.end.x + 1):
		for y in range(area.position.y, area.end.y + 1):
			for z in range(area.position.z, area.end.z + 1):
				var cell := Vector3i(x, y, z)

				if erase_empty_tiles:
					var has_cell: bool = false
					for layer in range(generator.grid.get_layer_count()):
						if generator.grid.has_cell(cell, layer) and generator.grid.get_value(cell, layer) != null:
							has_cell = true
							break

					if not has_cell:
						grid_map.call_thread_safe("set_cell_item", cell, -1)  # thread_safe paces these calls out when threaded.
						continue

				for layer in range(generator.grid.get_layer_count()):
					if only_draw_visible_cells and not generator.grid.has_empty_neighbor(cell, layer):
						continue

					var tile_info = generator.grid.get_value(cell, layer)
					if not (tile_info is GridmapTileInfo):
						continue

					grid_map.call_thread_safe("set_cell_item", cell, tile_info.index)  # thread_safe paces these calls out when threaded.

	(func(): area_rendered.emit(area)).call_deferred()


func _draw() -> void:
	grid_map.clear()
	super._draw()
