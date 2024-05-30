@tool
class_name ThreadedChunkLoader3D
extends ChunkLoader3D
## @experimental

var queued:Callable
var task:int = -1

func _process(_delta):
	if task > -1:
		if WorkerThreadPool.is_task_completed(task):
			WorkerThreadPool.wait_for_task_completion(task)
			task = -1
	super(_delta)

func _update_loading(actor_position: Vector3i) -> void:
	var job:Callable = func ():
		super._update_loading(actor_position)
	
	if task > -1:
		queued = job
	else:
		task = WorkerThreadPool.add_task(job, false, "Load/Unload Chunks")
