@icon("generator_parameters.svg")
class_name GeneratorParameters extends Resource


func _init() -> void:
	if resource_name == "":
		resource_name = "Parameters"
