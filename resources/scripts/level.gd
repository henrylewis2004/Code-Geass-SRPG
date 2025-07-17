class_name Level extends Node

signal sceneOver
signal resetScene

@export var nextLevel_path: String

func getNextLevelPath() -> String:
	return nextLevel_path

func sceneOver_emit() -> void:
	sceneOver.emit()

func resetScene_emit() -> void:
	resetScene.emit()
