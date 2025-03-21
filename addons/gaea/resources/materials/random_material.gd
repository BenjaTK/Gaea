@tool
class_name RandomMaterial
extends GaeaMaterial


@export var materials: Array[GaeaMaterial]


func get_resource() -> GaeaMaterial:
	return materials.pick_random().get_resource()
