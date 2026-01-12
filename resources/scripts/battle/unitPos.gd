@tool
class_name UnitPos extends Node

@export var set_position : Vector3

func _ready() -> void:
	var child = get_child(0) as BaseUnit
	child.position = set_position

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		var child = get_child(0) as BaseUnit
		child.position = set_position


