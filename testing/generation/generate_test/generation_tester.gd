extends Node2D

class_name GaeaGenerationTester


signal generation_ended


@onready var gaea_generator: GaeaGenerator = $GaeaGenerator

var last_grid: GaeaGrid
var last_cancelled: GaeaGenerationTask
var last_discarded: GaeaGenerationTask
var last_finished: GaeaGenerationTask
var timer: SceneTreeTimer


## Used for integration testing.
func test_generation(fixed_seed: int = 0, copies: int = 1) -> void:
	gaea_generator.settings.world_size = Vector3i(45, 45, 1)
	gaea_generator.settings.random_seed_on_generate = false
	gaea_generator.settings.seed = fixed_seed

	gaea_generator.generation_finished.connect(_set_last_grid)
	gaea_generator.task_pool.task_cancelled.connect(_set_last_cancelled)
	gaea_generator.task_pool.task_discarded.connect(_set_last_discarded)
	gaea_generator.task_pool.task_finished.connect(_set_last_finished)
	gaea_generator.generation_finished.connect(_on_generation_finished)

	# Timeout in case the generator hangs or otherwise never finishes
	timer = get_tree().create_timer(1)
	timer.timeout.connect(_on_generation_finished.bind(null))

	# Queue up the requested tasks
	print("Will generate %d times; there are %d tasks running already" % [
		copies, gaea_generator.task_pool._tasks.size()
	])
	for c in range(copies):
		gaea_generator.generate()

	# Wait for generation to end...
	await generation_ended

	# Wait an empty frame
	await get_tree().process_frame


func _on_generation_finished(result):
	# Disconnect everything
	timer.timeout.disconnect(_on_generation_finished.bind(null))
	gaea_generator.generation_finished.disconnect(_set_last_grid)
	gaea_generator.task_pool.task_cancelled.disconnect(_set_last_cancelled)
	gaea_generator.task_pool.task_discarded.disconnect(_set_last_discarded)
	gaea_generator.task_pool.task_finished.disconnect(_set_last_finished)
	gaea_generator.generation_finished.disconnect(_on_generation_finished)

	# We timed out
	if result == null:
		gaea_generator.cancel_generation()
		_set_last_grid(null)

	# Ended
	generation_ended.emit()


func _set_last_grid(grid):
	print("Grid set to %s" % grid)
	last_grid = grid


func _set_last_cancelled(task: GaeaTask):
	print("Cancelled %s" % task.description)
	last_cancelled = task


func _set_last_discarded(task: GaeaTask):
	print("Discarded %s" % task.description)
	last_discarded = task


func _set_last_finished(task: GaeaTask):
	print("Finished %s" % task.description)
	last_finished = task


func _on_generate_pressed() -> void:
	gaea_generator.generate()
