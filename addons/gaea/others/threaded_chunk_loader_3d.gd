@tool
class_name ThreadedChunkLoader3D
extends ChunkLoader3D
## @experimental
## A threaded version of [ChunkLoader3D], allowing generation code to run parallel to the main thread of your game.
##
## @tutorial(Chunk Generation): https://benjatk.github.io/Gaea/#/tutorials/chunk_generation
## @tutorial(Optimization): https://benjatk.github.io/Gaea/#/tutorials/optimization

@export var threaded: bool = true

var _queued: Callable
var _task: int = -1


func _process(_delta):
	if _task > -1:
		if WorkerThreadPool.is_task_completed(_task):
			WorkerThreadPool.wait_for_task_completion(_task)
			_task = -1
			run_job(_queued)
	super(_delta)


func _update_loading(actor_position: Vector3i) -> void:
	if not threaded:
		super(actor_position)
	else:
		var _job:Callable = func ():
			super._update_loading(actor_position)

		if _task > -1:
			_queued = _job
		else:
			run_job(_job)


func run_job(_job:Callable):
	if _job:
		_task = WorkerThreadPool.add_task(_job, false, "Load/Unload Chunks")
