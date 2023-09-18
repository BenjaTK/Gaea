@tool
class_name ChunkAwareModifier
extends Modifier
##@tutorial(Modifiers): https://benjatk.github.io/Gaea/#/modifiers


## [ChunkAwareModifier]s use this value to offset the noise seed to make this modifier unique.
## Random value by default.
@export var modifier_seed: int = 134178497321


func _init() -> void:
	modifier_seed = randi()


func apply(grid: Dictionary, generator: GaeaGenerator) -> Dictionary:
	if "noise" in self:
		if (self.get("use_generator_noise") == true and
				generator.settings.get("noise") != null):
			self.set("noise", generator.settings.noise)
		# check for necessary properties
		elif "random_noise_seed" in self:
			# check if random noise is enabled
			if self.get("random_noise_seed"):
				# generate random noise
				var noise = self.get("noise") as FastNoiseLite
				noise.seed = randi()

	return _apply_area(
		GaeaGenerator.get_area_from_grid(grid),
		grid,
		generator
	)


func apply_chunk(grid: Dictionary, generator: ChunkAwareGenerator, chunk_position: Vector2i) -> Dictionary:
	if "noise" in self:
		if (self.get("use_generator_noise") == true and
				generator.settings.get("noise") != null):
			self.set("noise", generator.settings.noise)
		# check for necessary properties
		elif "random_noise_seed" in self and "noise" in self and "settings" in generator:
			# check if random noise is enabled
			if self.get("random_noise_seed"):
				# apply generators noise to modifiers noisexxx
				var noise := self.get("noise") as FastNoiseLite
				var generator_settings := generator.get("settings") as HeightmapGenerator2DSettings
				noise.seed = modifier_seed + generator_settings.noise.seed

	return _apply_area(
		Rect2i(
			chunk_position * generator.chunk_size,
			Vector2i(generator.chunk_size, generator.chunk_size)
		),
		grid,
		generator
	)


func _apply_area(area: Rect2i, grid: Dictionary, _generator: GaeaGenerator) -> Dictionary:
	push_warning("%s doesn't have an `_apply_area` implementation" % resource_name)
	return {}
