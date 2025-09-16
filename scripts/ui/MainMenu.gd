class_name MainMenu extends Level

signal continueGame

@onready var menuSelect: MenuSelect = $mainMenuBox/MenuSelect
@onready var confirmationBox := preload("res://scenes/game logic/menus/Confirmation Window.tscn")
@onready var animPlayer: AnimationPlayer = $AnimationPlayer

var allowInput: bool = false

#main menu
@onready var mainMenuBox: Control = $mainMenuBox
@onready var startButtonText: Label = $startButton

func input() -> void:
	if Input.is_action_just_pressed("menu_start"):
		mainMenuBox.set_visible(true)
		menuSelect.enable(true)
		startButtonText.set_visible(false)


func _ready():
	menuSelect.enable(false)
	
	await animPlayer.animation_finished
	allowInput = true
	animPlayer.play("start_modulate")

	
func _process(delta):
	if allowInput:
		input()


func _on_menu_select_item_selected(item):
	match(item):
		"NEW GAME":
			sceneOver.emit()
		"CONTINUE":
			continueGame.emit()
		"LOAD GAME":
			pass
		"CONFIG":
			pass
		"EXIT":
			var confirmation: ConfirmationWindow = confirmationBox.instantiate()
			add_child(confirmation)

			confirmation.setTopLabel("EXIT?")
			confirmation.setPos((get_viewport().get_visible_rect().size / 2 ) - (confirmation.getWindowSize() / 2) + Vector2(0,20))
			
			menuSelect.enable(false)
			

			if await confirmation.confirm:
				get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
				get_tree().quit()
				
				
			#cancel
			remove_child(confirmation)
			confirmation.queue_free()
				
			menuSelect.enable(true)
		
