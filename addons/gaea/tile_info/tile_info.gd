@tool
@icon("tile_info.svg")
class_name TileInfo
extends Resource
## Generic class to be extended to pass in data to the
## [GaeaGenerator] in each cell. Each [GaeaGenerator] creates
## a grid of [TileInfo]s.
## @tutorial(Gaea's Resources): https://benjatk.github.io/Gaea/#/resources

## [b]Optional[/b]. Used by modifiers for filtering.
@export var id: String = "":
	set(value):
		id = value
		resource_name = id.to_pascal_case()
@export_range(0, 1000, 1, "or_greater") var layer: int = 0
