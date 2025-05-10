class_name GdUnitTestDiscoverer
extends RefCounted


static func run() -> void:
	prints("Running test discovery ..")
	GdUnitSignals.instance().gdunit_event.emit(GdUnitEventTestDiscoverStart.new())
	await Engine.get_main_loop().create_timer(.5).timeout

	var test_suite_directories :PackedStringArray = GdUnitCommandHandler.scan_test_directorys("res://" , GdUnitSettings.test_root_folder(), [])
	var scanner := GdUnitTestSuiteScanner.new()
	var _test_suites_to_process :Array[Node] = []
	for test_suite_dir in test_suite_directories:
		_test_suites_to_process.append_array(scanner.scan(test_suite_dir))

	var test_case_count :int = _test_suites_to_process.reduce(func (accum :int, test_suite :Node) -> int:
				return accum + test_suite.get_child_count(), 0)

	for test_suite in _test_suites_to_process:
		var ts_dto := GdUnitTestSuiteDto.of(test_suite)
		GdUnitSignals.instance().gdunit_add_test_suite.emit(ts_dto)

	prints("%d test suites discovered." % _test_suites_to_process.size())
	GdUnitSignals.instance().gdunit_event.emit(GdUnitEventTestDiscoverEnd.new(_test_suites_to_process.size(), test_case_count))
	await Engine.get_main_loop().process_frame
