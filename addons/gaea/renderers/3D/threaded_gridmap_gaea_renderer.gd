@tool
class_name ThreadedGridmapGaeaRenderer
extends GridmapGaeaRenderer
## A threaded verison of [GridmapGaeaRenderer], allowing rendering code to run parallel to the main thread of your game.
##
## Wrapper for [GridmapGaeaRenderer] that runs multiple [method GaeaRenderer3D._draw_area] calls
##  in parallel using the [WorkerThreadPool].
## @experimental
##
## @tutorial(Optimization): https://benjatk.github.io/Gaea/#/tutorials/optimization

## Whether or not to pass calls through to the default GridmapGaeaRenderer,
##  instead of threading them.
@export var threaded: bool = true
## Decides the maximum number of WorkerThreadPool tasks that can be created
##  before queueing new tasks. A negative value (-1) means there is no limit.
@export var task_limit: int = -1

var _queued: Array[Callable] = []
var _tasks: PackedInt32Array = []


func _process(_delta):
	for t in range(_tasks.size()-1, -1, -1):
		if WorkerThreadPool.is_task_completed(_tasks[t]):
			WorkerThreadPool.wait_for_task_completion(_tasks[t])
			_tasks.remove_at(t)
	if threaded:
		while task_limit >= 0 and _tasks.size() < task_limit and not _queued.is_empty():
			run_task(_queued.pop_front())


func _draw_area(area: AABB) -> void:
	if not threaded:
		super(area)
	else:
		var _new_task:Callable = func ():
			super._draw_area(area)

		if task_limit >= 0 and _tasks.size() >= task_limit:
			_queued.push_back(_new_task)
		else:
			run_task(_new_task)


func run_task(_task:Callable):
	if _task:
		_tasks.append(WorkerThreadPool.add_task(_task, false, "Draw Area"))
