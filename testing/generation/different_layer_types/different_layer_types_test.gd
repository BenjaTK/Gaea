extends GdUnitTestSuite


const TEST_SCENE = "uid://ci5wsuwfex7hj"


var result: GaeaResult
var generator_seed:int


func test_has_generated() -> void:
	var scene : GaeaGenerationTester = auto_free(load(TEST_SCENE).instantiate())
	var _runner := scene_runner(scene)
	scene.gaea_generator.task_pool.multithreaded = false
	await scene.test_generation(200)

	var finished := scene.last_finished
	assert_that(finished).is_not_null()
	assert_bool(finished.cancelled).is_false()
	assert_int(finished.finish_time).is_greater_equal(0)

	var task_pool := scene.gaea_generator.task_pool
	assert_int(task_pool._tasks.size()).is_equal(0)

	result = auto_free(scene.last_result)
	generator_seed = scene.gaea_generator.settings.seed
	assert_that(result).is_not_null()
	assert_dict(result._grid).is_not_empty()


func test_types_are_correct() -> void:
	assert_bool(typeof(result.get_layer(0)) == TYPE_VECTOR2)\
		.override_failure_message("Layer 0 is not of the right type.").is_true()
	assert_bool(typeof(result.get_layer(1)) == TYPE_INT)\
		.override_failure_message("Layer 1 is not of the right type.").is_true()
	assert_bool(typeof(result.get_layer(2)) == TYPE_BOOL)\
		.override_failure_message("Layer 2 is not of the right type.").is_true()
	assert_bool(typeof(result.get_layer(3)) == TYPE_DICTIONARY)\
		.override_failure_message("Layer 3 is not of the right type.").is_true()
	assert_bool(typeof(result.get_layer(4)) == TYPE_FLOAT)\
		.override_failure_message("Layer 4 is not of the right type.").is_true()
	assert_bool(typeof(result.get_layer(5)) == TYPE_BOOL)\
		.override_failure_message("Layer 5 is not of the right type.").is_true()

	assert_vector(result.get_layer(0))\
		.override_failure_message("Layer 0 doesn't have the correct value.").is_equal(Vector2(1.0, 2.0))
	assert_int(result.get_layer(1))\
		.override_failure_message("Layer 1 doesn't have the correct value.").is_equal(999)
	assert_bool(result.get_layer(2))\
		.override_failure_message("Layer 2 doesn't have the correct value.").is_true()
	assert_dict(result.get_layer(3))\
		.override_failure_message("Layer 3 doesn't have the correct value.").contains_key_value("min", 1.0).contains_key_value("max", 2.0)
	assert_float(result.get_layer(4))\
		.override_failure_message("Layer 4 doesn't have the correct value.").is_equal(999.0)
	assert_bool(result.get_layer(5))\
		.override_failure_message("Layer 5 doesn't have the correct value.").is_true()
