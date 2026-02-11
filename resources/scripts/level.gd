class_name Level extends Node

signal sceneOver
signal resetScene

@export var nextLevel_path: String
@export var dialogOnStart: bool
@export var dialogPath: String
@export var goToSaveRoom: bool = false

@export var dialogPlayer: DialogManager
@export var loadingScreen: bool = true

##
func start() -> void:
	if self.get_node("BattleController") != null:
		if dialogOnStart:
			dialogPlayer.endDialoge.connect(battleLevelStart)
		else:
			battleLevelStart()
			return

	if dialogOnStart && dialogPlayer != null:
		if dialogPath != "" && dialogPath != null:
			dialogPlayer.play(dialogPath)
			return
		dialogPlayer.play()

func battleLevelStart() -> void:
	self.get_node("BattleController").startLevel()

func getNextLevelPath() -> String:
	return nextLevel_path

func toLoadingScreen() -> bool:
	return loadingScreen

func setToLoadingScreen(go: bool) -> void:
	loadingScreen = go

func toSaveRoom() -> bool:
	return goToSaveRoom

func sceneOver_emit() -> void:
	sceneOver.emit()

func resetScene_emit() -> void:
	resetScene.emit()
