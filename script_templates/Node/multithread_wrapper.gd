@tool
extends Node
## @experimental

@export var threaded: bool = true
@export var max_running: int = 1

var queued: Array[Callable] = []
var _tasks: PackedInt32Array = []


func _process(_delta):
	for t in range(_tasks.size()-1, -1, -1):
		if WorkerThreadPool.is_task_completed(_tasks[t]):
			WorkerThreadPool.wait_for_task_completion(_tasks[t])
			_tasks.remove_at(t)
	if threaded:
		while max_running >= 0 and _tasks.size() < max_running and not queued.is_empty():
			run_job(queued.pop_front())
	#super(_delta) # not needed for TilemapGaeaRenderer


func _some_method(some_value) -> void:
	if not threaded:
		super(some_value)
	else:
		var _job:Callable = func ():
			super._some_method(area)

		if max_running >= 0 and _tasks.size() >= max_running:
			queued.push_back(_job)
		else:
			run_job(_job)


func run_job(_job:Callable):
	if _job:
		_tasks.append(WorkerThreadPool.add_task(_job, false, "Some Threaded _job"))
