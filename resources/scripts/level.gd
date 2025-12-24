class_name Level extends Node

signal sceneOver
signal resetScene

@export var nextLevel_path: String
@export var sceneTran: bool
@export var goToSaveRoom: bool = false

func getNextLevelPath() -> String:
	return nextLevel_path

func hasSceneTransition() -> bool:
	return sceneTran

func toSaveRoom() -> bool:
	return goToSaveRoom

func sceneOver_emit() -> void:
	sceneOver.emit()

func resetScene_emit() -> void:
	resetScene.emit()
