@tool
extends Node
## @experimental

@export var threaded: bool = true

var queued: Callable
var _task: int = -1


func _process(_delta):
	if _task > -1:
		if WorkerThreadPool.is_task_completed(_task):
			WorkerThreadPool.wait_for_task_completion(_task)
			_task = -1
			run_job(queued)
	super(_delta)


func _some_method(some_value) -> void:
	if not threaded:
		super(some_value)
	else:
		var _job:Callable = func ():
			super._some_method(some_value)

		if _task > -1:
			queued = _job
		else:
			run_job(_job)


func run_job(_job:Callable):
	if _job:
		_task = WorkerThreadPool.add_task(_job, false, "Some Threaded _job")
