@tool
class_name ThreadedGridmapGaeaRenderer
extends GridmapGaeaRenderer
## @experimental

@export var threaded:bool = true

var tasks:PackedInt32Array = []

func _process(_delta):
	for t in range(tasks.size()-1, 0, -1):
		if WorkerThreadPool.is_task_completed(tasks[t]):
			WorkerThreadPool.wait_for_task_completion(tasks[t])
			tasks.remove_at(t)
	#super(_delta) # not needed for TilemapGaeaRenderer

func _draw_area(area: AABB) -> void:
	if not threaded:
		super(area)
	else:
		var job:Callable = func ():
			super._draw_area(area)
		run_job(job)

func run_job(job:Callable):
	if job:
		tasks.append(WorkerThreadPool.add_task(job, false, "Draw Area"))
