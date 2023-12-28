@tool
extends Button
## Base code by Nathan Hoad (https://github.com/nathanhoad)
## at https://github.com/nathanhoad/godot_dialogue_manager


const RELEASES_URL := "https://api.github.com/repos/BenjaTK/Gaea/releases"
const LOCAL_CONFIG_PATH := "res://addons/gaea/plugin.cfg"


var editor_plugin: EditorPlugin

@onready var http_request: HTTPRequest = $HTTPRequest
@onready var download_dialog: AcceptDialog = $DownloadDialog
@onready var update_failed_dialog: AcceptDialog = $UpdateFailedDialog
@onready var download_update_panel: Control = $DownloadDialog/DownloadUpdatePanel


func _ready() -> void:
	hide()

	_check_for_update()


func _check_for_update() -> void:
	http_request.request(RELEASES_URL)


func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		return

	var current_version := _get_version()
	if current_version == null:
		push_error("Couldn't find the current Gaea version.")
		return

	var response = JSON.parse_string(body.get_string_from_utf8())
	if not (response is Array):
		return

	# GitHub releases are in order of creation, not order of version
	var versions = (response as Array).filter(func(release):
		var version: String = release.tag_name.substr(1)
		return _version_to_number(version) > _version_to_number(current_version)
	)
	if versions.size() > 0:
		download_update_panel.next_version_release = versions[0]
		text = "Gaea v%s available" % versions[0].tag_name.substr(1)
		show()


func _on_pressed() -> void:
	download_dialog.popup_centered()


func _on_download_update_panel_updated(new_version) -> void:
	download_dialog.hide()


	editor_plugin.get_editor_interface().get_resource_filesystem().scan()

	print_rich("\n[b]Updated Gaea to v%s\n" % new_version)
	editor_plugin.get_editor_interface().call_deferred("set_plugin_enabled", "gaea", true)
	editor_plugin.get_editor_interface().set_plugin_enabled("gaea", false)


func _on_download_update_panel_failed() -> void:
	download_dialog.hide()
	update_failed_dialog.popup_centered()


func _get_version() -> String:
	var config: ConfigFile = ConfigFile.new()

	config.load(LOCAL_CONFIG_PATH)
	return config.get_value("plugin", "version")


func _version_to_number(version: String) -> int:
	var bits = version.split(".")
	return bits[0].to_int() * 1000000 + bits[1].to_int() * 1000 + bits[2].to_int()


