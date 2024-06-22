@tool
extends Resource

var _version := "v0.2.0"

## How many characters per line to allow.
## 每行允许的最大字符数量。
@export var line_length := 175:
	set(v):
		line_length = v
		emit_changed()

## If true, will format on save.
## 如果开启，将在脚本保存时进行格式化。
@export var format_on_save := false:
	set(v):
		format_on_save = v
		emit_changed()

## The shortcut for formatting script.
## Default is "Shift+Alt+F"。
## 格式化脚本所使用的快捷键
## 默认为"Shift+Alt+F"。
@export var shortcut := _create_default_shortcut():
	set(v):
		if is_instance_valid(shortcut) and shortcut.changed.is_connected(emit_changed):
			shortcut.changed.disconnect(emit_changed)
		shortcut = v
		if is_instance_valid(shortcut) and not shortcut.changed.is_connected(emit_changed):
			shortcut.changed.connect(emit_changed)
		emit_changed()

## If true, will skip safety checks.
## 如果开启，则跳过安全检查。
@export var fast_but_unsafe := false:
	set(v):
		fast_but_unsafe = v
		emit_changed()

## The gdformat command to use on the command line, you might need to modify this option if the "gdformat" is not installed for all users.
## 用于格式化的gdformat命令，如果你的gdformat不是为所有用户安装时可能需要修改该选项。
@export var gdformat_command := "gdformat":
	set(v):
		gdformat_command = v
		emit_changed()

## The pip command to use on the command line, you might need to modify this option if the "python/pip" is not installed for all users.
## 用于安装/更新gdformat而使用的pip命令，如果你的python/pip不是为所有用户安装时可能需要修改该选项。
@export var pip_command := "pip":
	set(v):
		pip_command = v
		emit_changed()


func _init() -> void:
	shortcut = shortcut


func _create_default_shortcut() -> Shortcut:
	var default_shortcut := InputEventKey.new()
	default_shortcut.echo = false
	default_shortcut.pressed = true
	default_shortcut.keycode = KEY_F
	default_shortcut.shift_pressed = true
	default_shortcut.alt_pressed = true

	var shortcut = Shortcut.new()
	shortcut.events.push_back(default_shortcut)

	return shortcut
