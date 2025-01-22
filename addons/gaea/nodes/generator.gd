@tool
class_name GaeaGenerator
extends Node


signal generation_finished(grid: GaeaGrid)


@export var data: GaeaData
@export var seed: int = randi()
@export var random_seed_on_generate: bool = true
## Leave [param z] as [code]1[/code] for 2D worlds.
@export var world_size: Vector3i = Vector3i(128, 128, 1)


func _ready() -> void:
	if not Engine.is_editor_hint():
		generate()


func generate() -> void:
	data.generator = self
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
		AABB(Vector3i.ZERO, world_size),
		data,
		self
	)
