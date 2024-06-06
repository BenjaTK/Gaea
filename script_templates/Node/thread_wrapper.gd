@tool
class_name ThreadedNode
extends Node
## @experimental

@export var threaded:bool = true

var queued:Callable
var task:int = -1

func _process(_delta):
	if task > -1:
		if WorkerThreadPool.is_task_completed(task):
			WorkerThreadPool.wait_for_task_completion(task)
			task = -1
			run_job(queued)
	super(_delta)

func _some_method(some_value) -> void:
	if not threaded:
		super(some_value)
	else:
		var job:Callable = func ():
			super._some_method(some_value)
		
		if task > -1:
			queued = job
		else:
			run_job(job)

func run_job(job:Callable):
	if job:
		task = WorkerThreadPool.add_task(job, false, "Some Threaded Job")
