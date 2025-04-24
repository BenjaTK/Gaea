@tool
@icon("../../assets/types/material.svg")
class_name GaeaMaterial
extends Resource
## Used to tell the [GaeaRenderer] what to draw in a certain point.
## The result of a Gaea generation is a grid of this resource.
##
## This is an abstract class. On its own, it doesn't do anything,
## but it can be extended to hold data related to the method of rendering
## chosen. See [TileMapMaterial] and [GridMapMaterial].[br]
## It can also be used to hold sub-resources to be chosen programmatically. See [RandomMaterial].


@export_group("Preview", "preview_")
## Color used in previews in the graph interface or in the [GaeaMaterialGradient] inspector.
@export var preview_color: Color = Color.TRANSPARENT


func _init() -> void:
	if preview_color == Color.TRANSPARENT:
		preview_color = Color(randf(), randf(), randf())


## Normally returns itself, but can be overridden to return other [GaeaMaterial] resources
## depending on certain behavior.
func get_resource() -> GaeaMaterial:
	return self
