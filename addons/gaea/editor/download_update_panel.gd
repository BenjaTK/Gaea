@tool
extends Control

signal failed
signal updated(new_version: String)

const TEMP_FILE_PATH = "user://temp.zip"

@onready var http_request: HTTPRequest = $HTTPRequest
@onready var label: Label = $MarginContainer/VBoxContainer/Label
@onready var download_button: Button = %DownloadButton
@onready var release_notes_button: LinkButton = %ReleaseNotesButton

var next_version_release: Dictionary:
	set(value):
		next_version_release = value
		label.text = "v%s is available for download" % value.tag_name.substr(1)
		release_notes_button.uri = value.html_url


func _on_download_button_pressed() -> void:
	# Make sure the actual Gaea repo doesn't update itself accidentally.
	if FileAccess.file_exists("res://scenes/demos/cellular/cellular_demo.tscn"):
		push_error("You can't update Gaea from within itself.")
		failed.emit()
		return

	http_request.request(next_version_release.zipball_url)
	download_button.disabled = true
	download_button.text = "Downloading..."


func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		failed.emit()
		return

	# Save temporarily the download zip file.
	var zip_file: FileAccess = FileAccess.open(TEMP_FILE_PATH, FileAccess.WRITE)
	zip_file.store_buffer(body)
	zip_file.close()

	OS.move_to_trash(ProjectSettings.globalize_path("res://addons/gaea"))

	var zip_reader: ZIPReader = ZIPReader.new()
	zip_reader.open(TEMP_FILE_PATH)
	var files: PackedStringArray = zip_reader.get_files()

	# Get copy of assets folder
	var base_path := files[1]
	# Remove archive folder
	files.remove_at(0)
	# Remove assets folder
	files.remove_at(0)

	for path in files:
		var new_file_path: String = path.replace(base_path, "")
		# If it's a directory.
		if path.ends_with("/"):
			DirAccess.make_dir_recursive_absolute("res://addons/%s" % new_file_path)
		else:
			var file: FileAccess = FileAccess.open("res://addons/%s" % new_file_path, FileAccess.WRITE)
			file.store_buffer(zip_reader.read_file(path))

	zip_reader.close()
	DirAccess.remove_absolute(TEMP_FILE_PATH)

	updated.emit(next_version_release.tag_name.substr(1))
