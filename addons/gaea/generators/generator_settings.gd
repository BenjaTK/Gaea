@icon("generator_settings.svg")
class_name GeneratorSettings extends Resource


func _init() -> void:
	if resource_name == "":
		resource_name = "Settings"
