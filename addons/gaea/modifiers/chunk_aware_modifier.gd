@tool
class_name ChunkAwareModifier2D
extends Modifier2D
##@tutorial(Modifiers): https://benjatk.github.io/Gaea/#/modifiers


## [ChunkAwareModifier2D]s use this value to offset the noise seed to make this modifier unique.
## Random value by default.
@export var modifier_seed: int = 134178497321


func _init() -> void:
	modifier_seed = randi()


func apply(grid: GaeaGrid, generator: GaeaGenerator) -> void:
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
	_apply_area(
		generator.grid.get_area(),
		grid,
		generator
	)


func apply_chunk(grid: GaeaGrid, generator: ChunkAwareGenerator2D, chunk_position: Vector2i) -> void:
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

	_apply_area(
		Rect2i(
			chunk_position * generator.chunk_size,
			Vector2i(generator.chunk_size, generator.chunk_size)
		),
		grid,
		generator
	)


func _apply_area(area: Rect2i, grid: GaeaGrid, _generator: GaeaGenerator) -> void:
	push_warning("%s doesn't have an `_apply_area` implementation" % resource_name)
