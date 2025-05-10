@tool
extends EditorPlugin

const GdUnitTools := preload("res://addons/gdUnit4/src/core/GdUnitTools.gd")
const GdUnitTestDiscoverGuard := preload("res://addons/gdUnit4/src/core/discovery/GdUnitTestDiscoverGuard.gd")


var _gd_inspector :Node
var _server_node :Node
var _gd_console :Node
var _guard: GdUnitTestDiscoverGuard


func _enter_tree() -> void:
	if Engine.get_version_info().hex < 0x40200:
		prints("GdUnit4 plugin requires a minimum of Godot 4.2.x Version!")
		return
	GdUnitSettings.setup()
	# install the GdUnit inspector
	_gd_inspector = load("res://addons/gdUnit4/src/ui/GdUnitInspector.tscn").instantiate()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UR, _gd_inspector)
	# install the GdUnit Console
	_gd_console = load("res://addons/gdUnit4/src/ui/GdUnitConsole.tscn").instantiate()
	add_control_to_bottom_panel(_gd_console, "gdUnitConsole")
	_server_node = load("res://addons/gdUnit4/src/network/GdUnitServer.tscn").instantiate()
	Engine.get_main_loop().root.add_child.call_deferred(_server_node)
	prints("Loading GdUnit4 Plugin success")
	if GdUnitSettings.is_update_notification_enabled():
		var update_tool :Node = load("res://addons/gdUnit4/src/update/GdUnitUpdateNotify.tscn").instantiate()
		Engine.get_main_loop().root.add_child.call_deferred(update_tool)
	if GdUnit4CSharpApiLoader.is_mono_supported():
		prints("GdUnit4Net version '%s' loaded." % GdUnit4CSharpApiLoader.version())
	# connect to be notified for script changes to be able to discover new tests
	_guard = GdUnitTestDiscoverGuard.new()
	resource_saved.connect(_on_resource_saved)


func _exit_tree() -> void:
	if is_instance_valid(_gd_inspector):
		remove_control_from_docks(_gd_inspector)
		GodotVersionFixures.free_fix(_gd_inspector)
	if is_instance_valid(_gd_console):
		remove_control_from_bottom_panel(_gd_console)
		_gd_console.free()
	if is_instance_valid(_server_node):
		Engine.get_main_loop().root.remove_child.call_deferred(_server_node)
		_server_node.queue_free()
	GdUnitTools.dispose_all.call_deferred()
	prints("Unload GdUnit4 Plugin success")


func _on_resource_saved(resource :Resource) -> void:
	if resource is Script:
		_guard.discover(resource)
