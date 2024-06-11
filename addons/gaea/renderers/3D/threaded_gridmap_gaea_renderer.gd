@tool
class_name ThreadedGridmapGaeaRenderer
extends GridmapGaeaRenderer
## Wrapper for GridmapGaeaRenderer that runs multiple _draw_area calls
##  in parallel using the WorkerThreadPool.
## @experimental

## Whether or not to pass calls through to the default GridmapGaeaRenderer,
##  instead of threading them.
@export var threaded:bool = true
## Decides the maximum number of WorkerThreadPool tasks that can be created
##  before queueing new tasks. A negative value (-1) means there is no limit.
@export var task_limit:int = -1

var queued:Array[Callable] = []
var tasks:PackedInt32Array = []


func _process(_delta):
	for t in range(tasks.size()-1, -1, -1):
		if WorkerThreadPool.is_task_completed(tasks[t]):
			WorkerThreadPool.wait_for_task_completion(tasks[t])
			tasks.remove_at(t)
	if threaded:
		while task_limit >= 0 and tasks.size() < task_limit and not queued.is_empty():
			run_task(queued.pop_front())


func _draw_area(area: AABB) -> void:
	if not threaded:
		super(area)
	else:
		var new_task:Callable = func ():
			super._draw_area(area)

		if task_limit >= 0 and tasks.size() >= task_limit:
			queued.push_back(new_task)
		else:
			run_task(new_task)


func run_task(task:Callable):
	if task:
		tasks.append(WorkerThreadPool.add_task(task, false, "Draw Area"))
