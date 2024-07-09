@tool
@icon("chunk_loader.svg")
class_name ChunkLoader2D
extends Node2D
## Used to handle chunk loading and unloading with a [ChunkAwareGenerator2D].
## @tutorial(Chunk Generation): https://benjatk.github.io/Gaea/#/tutorials/chunk_generation

## The generator that loads the chunks.[br]
## [b]Note:[/b] If you're chaining generators together using [param next_pass],
## this has to be set to the first generator in the chain.
@export var generator: ChunkAwareGenerator2D
## Chunks will be loaded arround this Node.
## If set to null chunks will be loaded around (0, 0)
@export var actor: Node2D
## The distance around the actor which will be loaded.
## The actual loading area will be this value in all 4 directions.
@export var loading_radius: Vector2i = Vector2i(2, 2)
## Amount of miliseconds the loader waits before it checks if new chunks need to be loaded.
@export_range(0, 1, 1, "or_greater", "suffix:ms") var update_rate: int = 0
## Executes the loading process on ready [br]
## [b]Warning:[/b] No chunks might load if set to false.
@export var load_on_ready: bool = true
## If set to true, the Chunk Loader unloads chunks left behind
@export var unload_chunks: bool = true
## If set to true, will prioritize chunks closer to the [param actor].
@export var load_closest_chunks_first: bool = true

var _last_run: int = 0
var _last_position: Vector2i


func _ready() -> void:
	if Engine.is_editor_hint() or not is_instance_valid(generator):
		return

	await get_tree().process_frame

	generator.erase()
	if load_on_ready:
		_update_loading(_get_actors_position())


func _process(delta: float) -> void:
	if Engine.is_editor_hint() or not is_instance_valid(generator):
		return

	var current_time = Time.get_ticks_msec()
	if current_time - _last_run > update_rate:
		# todo make check loading
		_try_loading()
		_last_run = current_time


# checks if chunk loading is neccessary and executes if true
func _try_loading() -> void:
	var actor_position: Vector2i = _get_actors_position()

	if actor_position == _last_position:
		return

	_last_position = actor_position
	_update_loading(actor_position)


# loads needed chunks around the given position
func _update_loading(actor_position: Vector2i) -> void:
	if generator == null:
		push_error("Chunk loading failed because generator property not set!")
		return

	var required_chunks: PackedVector2Array = _get_required_chunks(actor_position)

	# remove old chunks
	if unload_chunks:
		var loaded_chunks: PackedVector2Array = generator.generated_chunks
		for i in range(loaded_chunks.size() - 1, -1, -1):
			var loaded: Vector2 = loaded_chunks[i]
			if not (loaded in required_chunks):
				generator.unload_chunk(loaded)

	# load new chunks
	for required in required_chunks:
		if not generator.has_chunk(required):
			generator.generate_chunk(required)


func _get_actors_position() -> Vector2i:
	# getting actors positions
	var actor_position := Vector2.ZERO
	if actor != null:
		actor_position = actor.global_position

	var map_position := generator.global_to_map(actor_position)
	var chunk_position := generator.map_to_chunk(map_position)

	return chunk_position


func _get_required_chunks(actor_position: Vector2i) -> PackedVector2Array:
	var chunks: Array[Vector2] = []

	var x_range = range(actor_position.x - abs(loading_radius).x, actor_position.x + abs(loading_radius).x + 1)
	var y_range = range(actor_position.y - abs(loading_radius).y, actor_position.y + abs(loading_radius).y + 1)

	for x in x_range:
		for y in y_range:
			chunks.append(Vector2(x, y))

	if load_closest_chunks_first:
		chunks.sort_custom(
			func(chunk1: Vector2, chunk2: Vector2): return (
				chunk1.distance_squared_to(actor_position) < chunk2.distance_squared_to(actor_position)
			)
		)
	return PackedVector2Array(chunks)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray

	if not is_instance_valid(generator):
		warnings.append("Generator is required!")

	return warnings
