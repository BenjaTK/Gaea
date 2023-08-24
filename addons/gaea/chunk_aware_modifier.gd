@tool
class_name ChunkAwareModifier
extends Modifier


## Chunk Modifiers use this value to offset the noise seed to make this modifier unique.
## Random value by default.
@export var modifier_seed: int = 134178497321


func _init() -> void:
	modifier_seed = randi()


func apply(grid: Dictionary, _generator: GaeaGenerator) -> Dictionary:
	# check for necessary properties
	if "random_noise_seed" in self and "noise" in self:
		# check if random noise is enabled
		if self.get("random_noise_seed"):
			# generate random noise
			var noise = self.get("noise") as FastNoiseLite
			noise.seed = randi()
	
	return _apply_area(
		GaeaGenerator.get_area_from_grid(grid),
		grid,
		_generator
	)


func apply_chunk(grid: Dictionary, generator: GaeaGenerator, chunk_position: Vector2i) -> Dictionary:
	# check for necessary properties
	if "random_noise_seed" in self and "noise" in self and "settings" in generator:
		# check if random noise is enabled
		if self.get("random_noise_seed"):
			# apply generators noise to modifiers noisexxx
			var noise := self.get("noise") as FastNoiseLite
			var generator_settings := generator.get("settings") as HeightmapGenerator2DSettings
			noise.seed = modifier_seed + generator_settings.noise.seed
	
	return _apply_area(
		Rect2i(
			chunk_position * GaeaGenerator.CHUNK_SIZE,
			Vector2i(GaeaGenerator.CHUNK_SIZE, GaeaGenerator.CHUNK_SIZE)
		),
		grid,
		generator
	)


func _apply_area(area: Rect2i, grid: Dictionary, _generator: GaeaGenerator) -> Dictionary:
	push_warning("%s doesn't have a `_apply_area` implementation" % resource_name)
	return {}
