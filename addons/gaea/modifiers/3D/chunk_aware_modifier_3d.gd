@tool
class_name ChunkAwareModifier3D
extends Modifier3D

## [ChunkAwareModifier3D]s use this value to offset the generator's seed to make this modifier unique.
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

	_apply_area(grid.get_area(), grid, generator)


func apply_chunk(grid: GaeaGrid, generator: ChunkAwareGenerator3D, chunk_position: Vector3i) -> void:
	if "noise" in self:
		if self.get("use_generator_noise") == true and generator.settings.get("noise") != null:
			self.set("noise", generator.settings.noise)
		else:
			var noise := self.get("noise") as FastNoiseLite
			noise.seed = salt + generator.seed

	_apply_area(AABB(chunk_position * generator.chunk_size, generator.chunk_size), grid, generator)


func _apply_area(area: AABB, grid: GaeaGrid, _generator: GaeaGenerator) -> void:
	push_warning("%s doesn't have an `_apply_area` implementation" % resource_name)


func _validate_property(property: Dictionary) -> void:
	super(property)
	if property.name == "noise" and self.get("use_generator_noise") == true:
		property.usage = PROPERTY_USAGE_NONE
