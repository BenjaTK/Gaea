@tool
extends EditorPlugin

const _GDScriptFormatterPreference = preload("scripts/preference.gd")

var _preference
var _has_format_tool_item: bool = false
var _has_install_update_tool_item: bool = false
var _install_task_id: int = -1
var _connection_list: Array[Resource] = []


func _init() -> void:
	var preference_res_file = (get_script() as Resource).resource_path.get_base_dir().path_join("format_preference.tres")
	if not FileAccess.file_exists(preference_res_file):
		_preference = _GDScriptFormatterPreference.new()
		ResourceSaver.save(_preference, preference_res_file)

	_preference = ResourceLoader.load(preference_res_file, "", ResourceLoader.CACHE_MODE_IGNORE)

	# Update script for plugin updating, then reload it.
	if _preference.script.resource_path != (_GDScriptFormatterPreference as Script).resource_path:
		# Get old properies
		var props = (_preference.get_script() as Script).get_script_property_list().filter(func(p): return p["usage"] & PROPERTY_USAGE_STORAGE != 0)
		props = props.map(func(p): return {"name": p["name"], "value": _preference.get(p["name"])})
		# Apply old properties
		_preference = _GDScriptFormatterPreference.new()
		for prop in props:
			if prop["name"] in _preference:
				_preference.set(prop["name"], prop["value"])
		# Apply old shortcut if valid
		var old_shortcut_file := (get_script() as Resource).resource_path.get_base_dir().path_join("format_shortcut.tres")
		if FileAccess.file_exists(old_shortcut_file):
			_preference.shortcut = load(old_shortcut_file).duplicate(true)
			DirAccess.remove_absolute(old_shortcut_file)
		# Save and reload.
		ResourceSaver.save(_preference, preference_res_file)
		_preference = load(preference_res_file)

	resource_saved.connect(_on_resource_saved)


func _enter_tree() -> void:
	_add_format_tool_item_and_command()

	if not _has_command(_get_pip_command()):
		_print_warning('"%s" is required for installing "gdtoolkit".' % _get_pip_command())
		_print_warning("\tPlease install it and ensure it can be found in your environment.")
	else:
		add_tool_menu_item("GDScriptFormatter: Install/Update gdtoolkit", install_or_update_gdtoolkit)
		_has_install_update_tool_item = true

	update_shortcut()


func _exit_tree() -> void:
	_remove_format_tool_item_and_command()
	if _has_install_update_tool_item:
		remove_tool_menu_item("GDScriptFormatter: Install/Update gdtoolkit")


func _shortcut_input(event: InputEvent) -> void:
	if not _has_format_tool_item:
		return
	var shortcut = _get_shortcut()
	if not is_instance_valid(shortcut):
		return
	if shortcut.matches_event(event) and event.is_pressed() and not event.is_echo():
		if format_script():
			get_tree().root.set_input_as_handled()


func format_script() -> bool:
	if not EditorInterface.get_script_editor().is_visible_in_tree():
		return false
	var current_script = EditorInterface.get_script_editor().get_current_script()
	if not is_instance_valid(current_script) or not current_script is GDScript:
		return false
	var code_edit: CodeEdit = EditorInterface.get_script_editor().get_current_editor().get_base_editor()

	var formatted := []
	if not _format_code(current_script.resource_path, code_edit.text, formatted):
		return false

	_reload_code_edit(code_edit, formatted.back())
	return true


func install_or_update_gdtoolkit() -> void:
	if _install_task_id >= 0:
		_print_warning("Installing or updating gdformat, please be patient.")
		return
	if not _has_command(_get_pip_command()):
		printerr('Installation of GDScript Formatter failed: Command "%s" is required, please ensure it can be found in your environment.' % _get_pip_command())
		return
	_install_task_id = WorkerThreadPool.add_task(_install_or_update_gdtoolkit, true, "Install or update gdtoolkit.")
	while _install_task_id >= 0:
		if not WorkerThreadPool.is_task_completed(_install_task_id):
			await get_tree().process_frame
		else:
			_install_task_id = -1


func update_shortcut() -> void:
	for obj in _connection_list:
		obj.changed.disconnect(update_shortcut)

	_connection_list.clear()

	var shortcut = _get_shortcut()
	if is_instance_valid(shortcut):
		for event in shortcut.events:
			event = event as InputEvent
			if is_instance_valid(event):
				event.changed.connect(update_shortcut)
				_connection_list.push_back(event)

	_remove_format_tool_item_and_command()
	_add_format_tool_item_and_command()


func _on_resource_saved(resource: Resource) -> void:
	# Preference
	var preference_path = (get_script() as Resource).resource_path.get_base_dir().path_join("format_preference.tres")
	if resource.resource_path == preference_path:
		_preference = load(preference_path)
		return

	# Format on save
	if not _preference.format_on_save:
		return

	var gds := resource as GDScript
	if resource == get_script():
		return

	if not _has_format_tool_item or not is_instance_valid(gds):
		return

	var formatted := []
	if not _format_code(gds.resource_path, gds.source_code, formatted):
		return

	gds.source_code = formatted.back()
	ResourceSaver.save(gds)
	gds.reload()

	var script_editor := get_editor_interface().get_script_editor()
	var open_script_editors := script_editor.get_open_script_editors()
	var open_scripts := script_editor.get_open_scripts()

	if not open_scripts.has(gds):
		return

	if script_editor.get_current_script() == gds:
		_reload_code_edit(script_editor.get_current_editor().get_base_editor(), formatted.back(), true)
	elif open_scripts.size() == open_script_editors.size():
		for i in range(open_scripts.size()):
			if open_scripts[i] == gds:
				_reload_code_edit(open_script_editors[i].get_base_editor(), formatted.back(), true)
				return
	else:
		printerr("GDScript Formatter error: Unknown situation, can't reload code editor in Editor. Please report this issue.")


func _install_or_update_gdtoolkit():
	var has_gdformat = _has_command(_get_gdformat_command())
	if has_gdformat:
		print("-- Beginning gdtoolkit update.")
	else:
		print("-- Beginning gdtoolkit installation.")

	var output := []
	var err := OS.execute(_get_pip_command(), ["install", "gdtoolkit"], output)
	if err == OK:
		if has_gdformat:
			print("-- Update of gdtoolkit successful.")
		else:
			print("-- Installation of gdtoolkit successful.")
		_add_format_tool_item_and_command()
	else:
		if has_gdformat:
			printerr("-- Update of gdtoolkit failed, exit code: ", err)
		else:
			printerr("-- Installation of gdtoolkit failed, exit code: ", err)
		printerr("\tPlease check below for more details.")
		print("\n".join(output))


func _add_format_tool_item_and_command() -> void:
	if _has_format_tool_item:
		return
	if not _has_command(_get_gdformat_command()):
		_print_warning('GDScript Formatter: The command "%s" can\'t be found in your environment.' % _get_gdformat_command())
		_print_warning('\tIf you have not installed "gdtoolkit", install it first.')
		_print_warning('\tIf you have installed "gdtoolkit", change "gdformat_command" to a valid command in "%s", and save this resource.' % _preference.resource_path)
		return
	add_tool_menu_item("GDScriptFormatter: Format script", format_script)
	var shortcut = _get_shortcut()
	EditorInterface.get_command_palette().add_command(
		"Format GDScript", "GDScript Formatter/Format GDScript", format_script, shortcut.get_as_text() if is_instance_valid(shortcut) else "None"
	)
	_has_format_tool_item = true


func _remove_format_tool_item_and_command() -> void:
	if not _has_format_tool_item:
		return
	_has_format_tool_item = false
	EditorInterface.get_command_palette().remove_command("GDScript Formatter/Format GDScript")
	remove_tool_menu_item("GDScriptFormatter: Format script")


func _has_command(command: String) -> bool:
	var output := []
	var err := OS.execute(command, ["--version"], output)

	return err == OK


func _reload_code_edit(code_edit: CodeEdit, new_text: String, tag_saved: bool = false) -> void:
	var column := code_edit.get_caret_column()
	var line := code_edit.get_caret_line()
	var scroll_hor := code_edit.scroll_horizontal
	var scroll_ver := code_edit.scroll_vertical

	code_edit.text = new_text
	if tag_saved:
		code_edit.tag_saved_version()

	code_edit.set_caret_column(column)
	code_edit.set_caret_line(line)
	code_edit.scroll_horizontal = scroll_hor
	code_edit.scroll_vertical = scroll_ver


func _format_code(script_path: String, code: String, formated: Array) -> bool:
	const tmp_file = "res://addons/gdscript_formatter/.tmp.gd"
	var f = FileAccess.open(tmp_file, FileAccess.WRITE)
	if not is_instance_valid(f):
		printerr("GDScript Formatter Error: Can't create tmp file.")
		return false
	f.store_string(code)
	f.close()

	var output := []
	var args := [ProjectSettings.globalize_path(tmp_file), "--line-length=%d" % _preference.line_length]
	if _preference.fast_but_unsafe:
		args.push_back("--fast")
	var err = OS.execute(_get_gdformat_command(), args, output)
	if err == OK:
		f = FileAccess.open(tmp_file, FileAccess.READ)
		formated.push_back(f.get_as_text())
		f.close()
	else:
		printerr("Format GDScript failed: ", script_path)
		printerr("\tExit code: ", err, " Output: ", output.front().strip_edges())
		printerr('\tIf your script does not have any syntax errors, this error is led by limitations of "gdtoolkit", e.g. multiline lambda.')

	DirAccess.remove_absolute(tmp_file)
	return err == OK


func _get_gdformat_command() -> String:
	return _preference.gdformat_command


func _get_pip_command() -> String:
	return _preference.pip_command


func _get_shortcut() -> Shortcut:
	return _preference.shortcut


func _print_warning(str: String) -> void:
	print_rich("[color=orange]%s[/color]" % str)
