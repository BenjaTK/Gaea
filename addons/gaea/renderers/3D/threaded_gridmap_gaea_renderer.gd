@tool
class_name ThreadedGridmapGaeaRenderer
extends GridmapGaeaRenderer
## @experimental

@export var threaded:bool = true
@export var max_running:int = 1

var queued:Array[Callable] = []
var tasks:PackedInt32Array = []

func _process(_delta):
	for t in range(tasks.size()-1, -1, -1):
		if WorkerThreadPool.is_task_completed(tasks[t]):
			WorkerThreadPool.wait_for_task_completion(tasks[t])
			tasks.remove_at(t)
	while tasks.size() < max_running and not queued.is_empty():
		run_job(queued.pop_front())
	#super(_delta) # not needed for TilemapGaeaRenderer

func _draw_area(area: AABB) -> void:
	if not threaded:
		super(area)
	else:
		var job:Callable = func ():
			super._draw_area(area)
		
		if max_running >= 0 and tasks.size() >= max_running:
			queued.push_back(job)
		else:
			run_job(job)

func run_job(job:Callable):
	if job:
		tasks.append(WorkerThreadPool.add_task(job, false, "Draw Area"))
