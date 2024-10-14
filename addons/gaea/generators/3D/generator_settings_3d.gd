@icon("../generator_settings.svg")
class_name GeneratorSettings3D
extends Resource
## @tutorial(Gaea's Resources): https://benjatk.github.io/Gaea/#/resources

@export var modifiers: Array[Modifier3D]  # TODO: Replace with custom control for easier editing. Similar to Blender.


func _init() -> void:
	if resource_name == "":
		resource_name = "Settings"
