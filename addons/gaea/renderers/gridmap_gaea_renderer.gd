@tool
class_name GridmapGaeaRenderer
extends GaeaRenderer3D


@export var grid_map: GridMap
## Draws only cells with an empty neighbor.
@export var only_draw_visible_cells: bool = true


func _draw_area(area: AABB) -> void:
	for x in range(area.position.x, area.end.x + 1):
		for y in range(area.position.y, area.end.y + 1):
			for z in range(area.position.z, area.end.z + 1):
				var tile_position := Vector3(x, y, z)
				if not generator.grid.has(tile_position):
					continue

				if only_draw_visible_cells and not GaeaGenerator3D.has_empty_neighbor(generator.grid, tile_position):
					continue

				var tile_info = generator.grid[tile_position]
				if not (tile_info is GridmapTileInfo):
					continue

				grid_map.set_cell_item(tile_position, tile_info.index)


func _draw() -> void:
	grid_map.clear()
	super._draw()
