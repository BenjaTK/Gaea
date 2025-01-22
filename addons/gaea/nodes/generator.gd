@tool
class_name GaeaGenerator
extends Node


signal generation_finished(generation_data: Dictionary)


@export var data: GaeaData
@export var seed: int = randi()
@export var random_seed_on_generate: bool = true
@export var world_size: Vector2i = Vector2i(128, 128)


func _ready() -> void:
	if not Engine.is_editor_hint():
		generate()


func generate() -> void:
	var connections: Array[Dictionary] = data.connections
	var output_resource: GaeaNodeResource

	for resource in data.resources:
		resource.connections.clear()

	for idx in connections.size():
		var connection: Dictionary = connections[idx]
		var resource: GaeaNodeResource = data.resources[connection.to_node]
		resource.connections.append(connection)

		if resource.is_output:
			output_resource = resource

	output_resource.execute(
		Rect2i(Vector2i.ZERO, world_size),
		data,
		self
	)
