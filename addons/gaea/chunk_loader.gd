@tool
@icon("chunk_loader.svg")
class_name ChunkLoader
extends Node2D


## The generator that loads the chunks.
@export var generator: ChunkAwareGenerator
## [b]Optional[/b]. In this case it is used to prevent
## generating chunks before the [GaeaRenderer] is ready, which
## prevents empty areas.
@export var renderer: GaeaRenderer
## Chunks will be loaded arround this Node.
## If set to null chunks will be loaded around (0, 0)
@export var actor: Node2D
## The distance around the actor which will be loaded.
## The actual loading area will be this value in all 4 directions.
@export var loading_radius: Vector2i = Vector2i(2, 2)
## Amount of frames the loader waits before it checks if new chunks need to be loaded.
@export_range(0, 10) var update_rate: int = 0
## Executes the loading process on ready [br]
## [b]Warning:[/b] No chunks might load if set to false.
@export var load_on_ready: bool = true
## If set to true, the Chunk Loader unloads chunks left behind
@export var unload_chunks: bool = true

var _update_status: int = 0
var _last_position: Vector2i


func _ready() -> void:
	generator.erase()
	if load_on_ready and not Engine.is_editor_hint():
		if is_instance_valid(renderer) and not renderer.is_node_ready():
			await renderer.ready
		_update_loading(_get_actors_position())


func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return

	_update_status -= 1
	if _update_status <= 0:
		# todo make check loading
		_try_loading()
		_update_status = update_rate


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

	var required_chunks: Array[Vector2i] = _get_required_chunks(actor_position)

	# remove old chunks
	if unload_chunks:
		var loaded_chunks: Array[Vector2i] = generator.generated_chunks
		for i in range(loaded_chunks.size() - 1, -1, -1):
			var loaded: Vector2i = loaded_chunks[i]
			if not (loaded in required_chunks):
				generator.unload_chunk(loaded)

	# load new chunks
	for required in required_chunks:
		if not generator.has_chunk(required):
			generator.generate_chunk(required)


func _get_actors_position() -> Vector2i:
	# getting actors positions
	var actor_position := Vector2i.ZERO
	if actor != null: actor_position = actor.global_position.floor()

	var tile_position: Vector2i = actor_position / generator.tile_size

	var chunk_position := Vector2i(
		floori(tile_position.x / generator.chunk_size),
		floori(tile_position.y / generator.chunk_size)
	)

	return chunk_position


func _get_required_chunks(actor_position: Vector2i) -> Array[Vector2i]:
	var chunks: Array[Vector2i] = []

	var x_range = range(
		actor_position.x - abs(loading_radius).x,
		actor_position.x + abs(loading_radius).x + 1
	)
	var y_range = range(
		actor_position.y - abs(loading_radius).y,
		actor_position.y + abs(loading_radius).y + 1
	)

	for x in x_range:
		for y in y_range:
			chunks.append(Vector2i(x, y))

	return chunks


func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray

	if not is_instance_valid(generator):
		warnings.append("Generator is required!")

	return warnings
