class_name GameOverManager extends Node

signal gameOverFinished(victory: bool) #true goto next scene, false reset scene

@export var endSceneDialog: bool = false
@export var dialogPath: String
@onready var dialogMan: DialogManager = $DialogManager

@export var screenImages: Array[Texture]

@onready var gameOverScreen: Control = $GameOverScreen
@onready var confirmMenu: Control = $GameOverScreen/confirmationMenu
@onready var menuSelect: MenuSelect = $GameOverScreen/confirmationMenu/MenuSelect

const textLoc: Array[Vector2] = [Vector2(4,1),Vector2(255,15)]

###
func playScript(scriptPath:String=dialogMan.getScriptPath()) -> void:

	dialogMan.play(scriptPath)


func gameOver(victory: bool) -> void:

	if endSceneDialog:
		dialogMan.visible = true
		dialogMan.getSceneScript(dialogPath)
		await dialogMan.endDialoge

	if victory: 
		menuSelect.setMenu($GameOverScreen/confirmationMenu/victory/options)
		gameOverScreen.get_child(0).texture = screenImages[1]
		confirmMenu.position = textLoc[1]

		confirmMenu.get_child(1).visible = true
		confirmMenu.get_child(0).visible = false
	else:
		menuSelect.setMenu($GameOverScreen/confirmationMenu/defeat/options)
		gameOverScreen.get_child(0).texture = screenImages[0]
		confirmMenu.position = textLoc[0]

		confirmMenu.get_child(0).visible = true
		confirmMenu.get_child(1).visible = false

	menuSelect.enable(true)
	gameOverScreen.visible = true


func input(input:String) -> void:
	match(input):
		"exit":
			get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
			get_tree().quit()
			return

	gameOverFinished.emit(input == "continue")

#engine
func _ready() -> void:
	gameOverScreen.visible = false
	if !endSceneDialog:
		self.remove_child(dialogMan)
		dialogMan.queue_free()
	else:
		dialogMan.visible = false
