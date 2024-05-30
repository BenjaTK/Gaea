@tool
@icon("../2D/heightmap_painter.svg")
class_name HeightmapPainter3D
extends ChunkAwareModifier3D
## Replaces tiles in the map with [param tile] based on a noise heightmap.
## @tutorial(Heightmap Painter Modifier): https://benjatk.github.io/Gaea/#/modifiers?id=-heightmap-painter


## Overrides [param noise] in favor of using the generator's noise (if it has one).[br]
## Useful for use with the [HeightmapGenerator2D], as it will make sure it follows
## the same terrain shape (especially if [param height_intensity] is the same as the generator's).
@export var use_generator_noise: bool = true :
	set(value):
		use_generator_noise = value
		notify_property_list_changed()
@export var ignore_empty_cells: bool = true
@export var noise: FastNoiseLite = FastNoiseLite.new()
@export var tile: TileInfo
## The medium height at which the painter will start replacing tiles.
## The heightmap displaces this height by a random number
## between -[param height_intensity] and [param height_intensity].[br]
## Negative values will go below y=0.
@export var height_offset := 128
## The heightmap displaces [param height_offset] by a random number
## from -[param height_intensity] to [param height_intensity].
@export var height_intensity := 20


func _apply_area(area: AABB, grid: GaeaGrid, _generator: GaeaGenerator) -> void:
	for x in range(area.position.x, area.end.x + 1):
		for z in range(area.position.z, area.end.z + 1):
			for y in range(area.position.y, area.end.y + 1):
				var cell := Vector3i(x, y, z)
				if not grid.has_cell(cell, tile.layer) and ignore_empty_cells:
					continue

				var height = floor(noise.get_noise_2d(x, z) * height_intensity + height_offset)
				if y <= height:
					if not _passes_filter(grid, cell):
						continue

					grid.set_value(cell, tile)


func _validate_property(property: Dictionary) -> void:
	super(property)
	if property.name == "affected_layers":
		property.usage = PROPERTY_USAGE_NONE
