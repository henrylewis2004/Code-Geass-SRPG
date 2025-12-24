class_name SaveRoom extends Level

signal exitToMenu
signal saveChosen
signal writeSave(slot:int)

@onready var menuSelect: MenuSelect = $usrSelection/MenuSelect

enum STATES{MODE_SELECTION,SLOT,SLOT_CONFIRM}
var state: int = STATES.MODE_SELECTION

##
func confirmWindow(topLabelText:String,confirmationSignal:Signal,signalData:int=-1) -> void:
		var confirmation: ConfirmationWindow = load("res://scenes/game logic/menus/Confirmation Window.tscn").instantiate()
		add_child(confirmation)

		confirmation.setTopLabel(topLabelText)
		confirmation.setPos((get_viewport().get_visible_rect().size / 2 ) - (confirmation.getWindowSize() / 2) + Vector2(0,20))

		menuSelect.enable(false)

		if await confirmation.confirm:
			if signalData >= 0:
				confirmationSignal.emit(signalData)
				return
			confirmationSignal.emit()
			return
			
		#cancel
		remove_child(confirmation)
		confirmation.queue_free()
			
		menuSelect.enable(true)
		menuSelect.setIndex(1)


#input
func input() -> void:
	if Input.is_action_just_pressed("cancel"):
		match(state):
			STATES.SLOT_CONFIRM:
				var saveSelector: Control = self.get_node("usrSelection").get_node("SaveSelector")
				saveSelector.set_visible(true)
				menuSelect.setMenu(saveSelector.get_node("HBoxContainer"))

				menuSelect.itemSelected.disconnect(playerSelection)
				menuSelect.itemSelected.connect(playerSaveSlotSelection)

				menuSelect.enable(true)
				state = STATES.SLOT

			STATES.SLOT:
				findUserInput()



func playerSelection(input: String) -> void:
	print(input)
	match(input):
		"continue":
			sceneOver.emit()
		"save":
			menuSelect.enable(false)
			saveChosen.emit()
		"exit":
			confirmWindow("EXIT TO MENU?",exitToMenu)

func playerSaveSlotSelection(input: String) -> void:
	confirmWindow("SAVE TO SLOT " + str(input[4]) + "?",writeSave,int(input[4]))
	state = STATES.SLOT_CONFIRM
	


func setNextLevel(levelPath: String) -> void:
	nextLevel_path = levelPath

func findUserInput() -> void:
	for child in get_children():
		if child is ConfirmationWindow:
			remove_child(child)
			child.queue_free()
			break

	self.get_node("usrSelection/SaveSelector").set_visible(false)

	menuSelect.setMenu(self.get_node("usrSelection/HBoxContainer"))

	menuSelect.itemSelected.disconnect(playerSaveSlotSelection)
	menuSelect.itemSelected.connect(playerSelection)

	menuSelect.enable(true)
	menuSelect.setIndex(1)

	state = STATES.MODE_SELECTION

func userSaveSlot(times:Array[String],levels:Array[String],dates:Array[String]) -> void:
	var saveSelector: Control = self.get_node("usrSelection/SaveSelector")
	saveSelector.set_visible(true)
	menuSelect.setMenu(saveSelector.get_node("HBoxContainer"))

	var labels = saveSelector.get_node("HBoxContainer").get_children()
	for i in range(labels.size()):
		labels[i].text = "Slot " + str(i + 1)

		if levels[i] == "":
			labels[i].text += "\n(EMPTY)"
		else:
			labels[i].text += "\n("+ dates[i] +")"+"\n("+times[i]+")"


	menuSelect.itemSelected.disconnect(playerSelection)
	menuSelect.itemSelected.connect(playerSaveSlotSelection)

	menuSelect.enable(true)
	state = STATES.SLOT



#engine
func _ready() -> void:
	goToSaveRoom = false
	findUserInput()

func _process(delta) -> void:
	input()
