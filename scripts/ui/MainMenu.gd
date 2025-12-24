class_name MainMenu extends Level

signal continueGame
signal loadSlot(slot:int)
signal deleteSlot(slot:int)
signal refreshSaveSlots(level: MainMenu)

@onready var menuSelect: MenuSelect = $mainMenuBox/MenuSelect
#@onready var confirmationBox := preload("res://scenes/game logic/menus/Confirmation Window.tscn")
const confirmationBox := preload("res://scenes/game logic/menus/Confirmation Window.tscn")
@onready var animPlayer: AnimationPlayer = $AnimationPlayer

#state
enum STATES{INIT,MENU_OPTION,LOAD_SCREEN,CONFIG_SCREEN,CONFIRM}
var curState: int = STATES.INIT

#main menu
@onready var mainMenuBox: Control = $mainMenuBox
@onready var startButtonText: Label = $startButton

@onready var saveSelector: Control = $SaveSelector

## confirmation box
func confirm(topLabelText: String) -> ConfirmationWindow:
		curState = STATES.CONFIRM

		var confirmation: ConfirmationWindow = confirmationBox.instantiate()
		add_child(confirmation)
		confirmation.setTopLabel(topLabelText)
		confirmation.setPos((get_viewport().get_visible_rect().size / 2 ) - (confirmation.getWindowSize() / 2) + Vector2(0,20))
		
		menuSelect.enable(false)

		return confirmation
		

func updateSlotInfo(slotInfo: Array) -> void:
	var labels = saveSelector.get_node("HBoxContainer").get_children()

	for i in range(labels.size()):
		labels[i].text = "Slot " + str(i + 1)

		if slotInfo[1][i] == "":
			labels[i].text += "\n(EMPTY)"
		else:
			labels[i].text += "\n("+ slotInfo[2][i] +")"+"\n("+slotInfo[0][i]+")"


####
func input() -> void:
	if Input.is_action_just_pressed("cancel"):
		match(curState):
			STATES.MENU_OPTION:
				curState = STATES.INIT

				mainMenuBox.set_visible(false)
				menuSelect.enable(false)
				startButtonText.set_visible(true)

				animPlayer.play("start_modulate")

			STATES.LOAD_SCREEN:
				saveSelector.set_visible(false)

				menuSelect.itemSelected.disconnect(_on_menu_slot_selection)
				menuSelect.itemSelected.connect(_on_menu_select_item_selected)

				menuInputScreen()
	
	elif Input.is_action_just_pressed("delete_save_slot"):
		var selectionSlot: int = menuSelect.getIndex() + 1
		var confirmation : ConfirmationWindow = confirm("Delete Save Slot "+str(selectionSlot)+"?")

		if await confirmation.confirm:
			deleteSlot.emit(selectionSlot)

			
		remove_child(confirmation)
		confirmation.queue_free()

		loadScreen()

		
			
func menuInputScreen() -> void:
	curState = STATES.MENU_OPTION
	startButtonText.set_visible(false)

	mainMenuBox.set_visible(true)
	menuSelect.setMenu(mainMenuBox.get_node("action/VBoxContainer"))
	menuSelect.enable(true)

func loadScreen() -> void:
	refreshSaveSlots.emit(self)
	curState = STATES.LOAD_SCREEN

	startButtonText.set_visible(false)
	mainMenuBox.set_visible(false)

	menuSelect.setMenu(saveSelector.get_node("HBoxContainer"))
	saveSelector.set_visible(true)
	menuSelect.enable(true)

	menuSelect.itemSelected.disconnect(_on_menu_select_item_selected)
	menuSelect.itemSelected.connect(_on_menu_slot_selection)

##

func _ready():
	menuSelect.enable(false)
	
	await animPlayer.animation_finished
	animPlayer.play("start_modulate")

	
func _process(delta):
	if curState > STATES.INIT:
		input()
	elif curState == STATES.INIT:
		if Input.is_action_just_pressed("ui_accept"): 
			menuInputScreen()


func _on_menu_select_item_selected(item):
	match(item):
		"NEW GAME":
			sceneOver.emit()
		"CONTINUE":
			continueGame.emit()
		"LOAD GAME":
			loadScreen()
		"CONFIG":
			curState = STATES.CONFIG_SCREEN
		"EXIT":
			var confirmation : ConfirmationWindow = confirm("EXIT?")

			if await confirmation.confirm:
				get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
				get_tree().quit()
				
			#cancel
			else:
				remove_child(confirmation)
				confirmation.queue_free()

				menuInputScreen()

		
func _on_menu_slot_selection(input:String) -> void:
	loadSlot.emit(int(input[4]))
