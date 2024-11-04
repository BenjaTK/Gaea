@tool
class_name GaeaGenerator
extends Node


signal generation_finished(generation_data: Dictionary)


@export var seed: int = randi()
@export var random_seed_on_generate: bool = true
@export var data: GaeaData
