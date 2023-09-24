@tool
@icon("chunk_loader.svg")
class_name ChunkLoader3D
extends Node3D


## The generator that loads the chunks.
@export var generator: ChunkAwareGenerator3D
## [b]Optional[/b]. In this case it is used to prevent
## generating chunks before the [GaeaRenderer] is ready, which
## prevents empty areas.
@export var renderer: GaeaRenderer3D
## Chunks will be loaded arround this Node.
## If set to null chunks will be loaded around (0, 0)
@export var actor: Node3D
## The distance around the actor which will be loaded.
## The actual loading area will be this value in all 4 directions.
@export var loading_radius: Vector3i = Vector3i(2, 2, 2)
## Amount of frames the loader waits before it checks if new chunks need to be loaded.
@export_range(0, 10) var update_rate: int = 0
## Executes the loading process on ready [br]
## [b]Warning:[/b] No chunks might load if set to false.
@export var load_on_ready: bool = true
## If set to true, the Chunk Loader unloads chunks left behind
@export var unload_chunks: bool = true
@export_group("Multithreading")
@export var multithreading: bool = false
## Use the user's processor count for the amount of threads.
@export var use_processor_count: bool = true
@export var custom_thread_amount: int = 5

var threads: Array[Thread]
var mutex = Mutex.new()
var _update_status: int = 0
var _last_position: Vector3i
var required_chunks: Array[Vector3i]


func _ready() -> void:
	if multithreading:
		for i in OS.get_processor_count() if use_processor_count else custom_thread_amount:
			threads.append(Thread.new())


		threads[0].start(_erase_threaded.bind(threads[0]))
	else:
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

	var actor_position: Vector3i = actor.global_position

	if actor_position == _last_position and required_chunks.is_empty():
		return

	_last_position = actor_position
	_update_loading(_get_actors_position())


# loads needed chunks around the given position
func _update_loading(actor_position: Vector3i) -> void:
	if is_instance_valid(renderer) and not renderer.is_node_ready():
		await renderer.ready

	if generator == null:
		push_error("Chunk loading failed because generator property not set!")
		return

	required_chunks = _get_required_chunks(actor_position)

	# remove old chunks
	if unload_chunks:
		var loaded_chunks: Array[Vector3i] = generator.generated_chunks
		for i in range(loaded_chunks.size() - 1, -1, -1):
			var loaded: Vector3i = loaded_chunks[i]
			if not (loaded in required_chunks):
				if multithreading:
					for thread in threads:
						if not thread.is_started():
							mutex.lock()
							thread.start(_unload_chunk_threaded.bind(loaded, thread))
							mutex.unlock()
							break
				else:
					generator.unload_chunk(loaded)


	# load new chunks
	for required in required_chunks:
		if not generator.has_chunk(required):
			if multithreading:
				for thread in threads:
					if not thread.is_started():
						mutex.lock()
						thread.start(_generate_chunk_threaded.bind(required, thread))
						mutex.unlock()
						required_chunks.erase(required)
						break
			else:
				generator.generate_chunk(required)


func _generate_chunk_threaded(chunk_position: Vector3i, thread: Thread = null) -> void:
	mutex.lock()
	generator.generate_chunk.call_deferred(chunk_position)
	mutex.unlock()

	if thread != null:
		_thread_complete.call_deferred(thread)


func _unload_chunk_threaded(chunk_position: Vector3i, thread: Thread = null) -> void:
	mutex.lock()
	generator.unload_chunk.call_deferred(chunk_position)
	mutex.unlock()

	if thread != null:
		_thread_complete.call_deferred(thread)


func _erase_threaded(thread: Thread) -> void:
	mutex.lock()
	generator.erase.call_deferred()
	mutex.unlock()

	if thread != null:
		_thread_complete.call_deferred(thread)


func _thread_complete(thread: Thread) -> void:
	if thread != null:
		thread.wait_to_finish()


func _get_actors_position() -> Vector3i:
	# getting actors positions
	var actor_position := Vector3i.ZERO
	if actor != null: actor_position = actor.global_position.floor()

	var tile_position: Vector3i = actor_position / generator.tile_size

	var chunk_position := Vector3i(
		floori(tile_position.x / generator.chunk_size),
		floori(tile_position.y / generator.chunk_size),
		floori(tile_position.z / generator.chunk_size)
	)

	return chunk_position


func _get_required_chunks(actor_position: Vector3i) -> Array[Vector3i]:
	var chunks: Array[Vector3i] = []

	var x_range = range(
		actor_position.x - abs(loading_radius).x,
		actor_position.x + abs(loading_radius).x + 1
	)
	var y_range = range(
		actor_position.y - abs(loading_radius).y,
		actor_position.y + abs(loading_radius).y + 1
	)
	var z_range = range(
		actor_position.z - abs(loading_radius).z,
		actor_position.z + abs(loading_radius).z + 1
	)

	for x in x_range:
		for y in y_range:
			for z in z_range:
				chunks.append(Vector3i(x, y, z))

	# Sort based on distance to player.
	chunks.sort_custom(
		func(a, b) -> bool:
			return abs(actor_position - a) < abs(actor_position - b)
			)
	return chunks


func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray

	if not is_instance_valid(generator):
		warnings.append("Generator is required!")

	return warnings


func _exit_tree() -> void:
	for thread in threads:
		if thread.is_started():
			thread.wait_to_finish()
