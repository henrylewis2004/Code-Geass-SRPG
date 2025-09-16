class_name Level extends Node

signal sceneOver
signal resetScene

@export var nextLevel_path: String
@export var sceneTran: bool

func getNextLevelPath() -> String:
	return nextLevel_path

func sceneTransition() -> bool:
	return sceneTran

func sceneOver_emit() -> void:
	sceneOver.emit()

func resetScene_emit() -> void:
	resetScene.emit()
