@tool
class_name GaeaGenerator
extends Node


signal generation_finished(generation_data: Dictionary)


@export var data: GaeaData
@export var seed: int = randi()
@export var random_seed_on_generate: bool = true
@export var world_size: Vector2i = Vector2i(128, 128)
