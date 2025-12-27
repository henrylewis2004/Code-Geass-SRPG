class_name Level extends Node

signal sceneOver
signal resetScene
signal sceneTransitionOver

@export var nextLevel_path: String
@export var sceneTran: bool
@export var dialogPath: String
@export var dialogOnStart: bool
@export var goToSaveRoom: bool = false

@export var dialogPlayer: DialogManager
@export var animPlayer: AnimationPlayer

##
func start() -> void:
	if sceneTran:
		playSceneTransition()

	if self.get_node("BattleController") != null:
		if dialogOnStart:
			dialogPlayer.endDialoge.connect(battleLevelStart)
		else:
			battleLevelStart()
			return

	if dialogOnStart:
		if dialogPath != "" || dialogPath != null:
			dialogPlayer.play(dialogPath)
			return
		dialogPlayer.play()

func battleLevelStart() -> void:
	self.get_node("BattleController").startLevel()

func playSceneTransition() -> void:
	animPlayer.play("animIntro")
	await animPlayer.animatinoFinished
	sceneTransitionOver.emit()


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
