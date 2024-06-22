@tool
class_name ChunkAwareModifier2D
extends Modifier2D
##@tutorial(Modifiers): https://benjatk.github.io/Gaea/#/modifiers

## [ChunkAwareModifier2D]s use this value to offset the generator's seed to make this modifier unique.
## Random value by default.
@export var salt: int = 134178497321


func _init() -> void:
	salt = randi()


func apply(grid: GaeaGrid, generator: GaeaGenerator) -> void:
	if "noise" in self:
		if self.get("use_generator_noise") == true and generator.settings.get("noise") != null:
			self.set("noise", generator.settings.noise)
		else:
			var noise := self.get("noise") as FastNoiseLite
			noise.seed = salt + generator.seed

	_apply_area(generator.grid.get_area(), grid, generator)


func apply_chunk(grid: GaeaGrid, generator: ChunkAwareGenerator2D, chunk_position: Vector2i) -> void:
	if "noise" in self:
		if self.get("use_generator_noise") == true and generator.settings.get("noise") != null:
			self.set("noise", generator.settings.noise)
		else:
			var noise := self.get("noise") as FastNoiseLite
			noise.seed = salt + generator.seed

	_apply_area(Rect2i(chunk_position * generator.chunk_size, generator.chunk_size), grid, generator)


func _apply_area(area: Rect2i, grid: GaeaGrid, _generator: GaeaGenerator) -> void:
	push_warning("%s doesn't have an `_apply_area` implementation" % resource_name)


func _validate_property(property: Dictionary) -> void:
	super(property)
	if property.name == "noise" and self.get("use_generator_noise") == true:
		property.usage = PROPERTY_USAGE_NONE
