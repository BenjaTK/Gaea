@tool
extends Node
## @experimental

@export var threaded: bool = true

var queued: Array[Callable]
var task: int = -1

func _process(_delta):
	if task > -1:
		if WorkerThreadPool.is_task_completed(task):
			WorkerThreadPool.wait_for_task_completion(task)
			task = -1
			if not queued.is_empty():
				run_job(queued.pop_front())
	#super(_delta) # not needed for TilemapGaeaRenderer


func _some_method(some_value) -> void:
	if not threaded:
		super(some_value)
	else:
		var job:Callable = func ():
			super._some_method(some_value)

		if task > -1:
			queued.push_back(job)
		else:
			run_job(job)


func run_job(job:Callable):
	if job:
		task = WorkerThreadPool.add_task(job, false, "Some Thread Job")
