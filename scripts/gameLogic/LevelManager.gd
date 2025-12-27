class_name LevelManager extends Node

const saveRoomScene := preload("res://scenes/levels/menu/saveRoom.tscn")
@onready var curLevel : Level = get_child(0)
var saveMan: SaveManager = SaveManager.new()

func connectScene(scene:Level) -> void:
	scene.resetScene.connect(resetLevel)
	scene.sceneOver.connect(nextLevel)
	
	if scene is MainMenu:
		scene.continueGame.connect(loadRecentSave)
		scene.loadSlot.connect(loadSaveSlot)
		scene.refreshSaveSlots.connect(updateMenuSlot)
		scene.deleteSlot.connect(deleteSlot)

func resetLevel() -> void:
	var curLevelPath := curLevel.scene_file_path
	for child in get_children():
		remove_child(child)
		child.queue_free()
		
	curLevel = load(curLevelPath).instantiate()
	add_child(curLevel)
	
	connectScene(curLevel)

func goToMenu() -> void:
	const mainMenuPath: String = "res://scenes/levels/menu/mainMenu.tscn"
	for child in get_children():
		remove_child(child)
		child.queue_free()

	curLevel = load(mainMenuPath).instantiate()
	add_child(curLevel)
	
	connectScene(curLevel)


#load level from save
func loadSaveSlot(slot:int) -> void:
	var saveSlotLevel: String = saveMan.getSaveSlotLevel(slot)
	if saveSlotLevel != "":
		loadLevel(saveMan.getSaveSlotLevel(slot))

func loadRecentSave() -> void:
	var recentSlot: int = saveMan.getRecentSaveSlot()
	if recentSlot >= 0:
		loadSaveSlot(recentSlot)

	else:	#no save
		pass


#saving
func deleteSlot(slot:int) -> void:
	print(slot)
	saveMan.deleteSave(slot)


func saveState(slot:int,time:String,date:String,seconds:String,levelPath:String=curLevel.getNextLevelPath()) -> void:
	saveMan.saveComplete.connect(curLevel.findUserInput)
	saveMan.writeSave(slot,time,date,seconds,levelPath)
	saveMan.saveComplete.disconnect(curLevel.findUserInput)

func getSaveInfo() -> Array:
	var saveTimes: Array[String] = saveMan.getSaveTimes()
	var saveLevels: Array[String] = saveMan.getSaveLevels()
	var saveDates: Array[String] = saveMan.getSaveDates()

	return [saveTimes,saveLevels,saveDates]

func updateMenuSlot(level: MainMenu) -> void:
	level.updateSlotInfo(getSaveInfo())

func findSaveSlot() -> void:
	var saveInfo := getSaveInfo()
	curLevel.writeSave.connect(saveSlot)

	curLevel.userSaveSlot(saveInfo[0],saveInfo[1],saveInfo[2])

func saveSlot(slot:int) -> void:
	var date: Dictionary = Time.get_datetime_dict_from_system()

	#date
	var timeDate :String = str(date["day"]) if date["day"] > 9 else ("0" + str(date["day"]))
	timeDate += "/" + (str(date["month"]) if date["month"] > 9 else ("0" + str(date["month"])))
	timeDate += "/"+ str(date["year"])

	#time
	var time :String = str(date["hour"]) if date["hour"] > 9 else ("0" + str(date["hour"])) #hour
	time += ":" + (str(date["minute"]) if date["minute"] > 9 else ("0" + str(date["minute"]))) #minute

	var seconds: String = str(date["second"]) if date["second"] > 9 else ("0" + str(date["second"]))
	saveState(slot,time,timeDate,seconds)

###
func loadLevel(levelPath: String,level:Level = curLevel) -> void:
	var saveRoom: bool = level.toSaveRoom()

	for child in get_children():
		remove_child(child)
		child.queue_free()
		
	if saveRoom:
		curLevel= saveRoomScene.instantiate()
		curLevel.setNextLevel(levelPath)
		curLevel.exitToMenu.connect(goToMenu)
		curLevel.saveChosen.connect(findSaveSlot)

	else:
		curLevel = load(levelPath).instantiate()

	add_child(curLevel)
	connectScene(curLevel)

	curLevel.start()
	
func nextLevel() -> void:
	var nextLevelPath: String = curLevel.getNextLevelPath()
	loadLevel(nextLevelPath)
	
	
	
#engine
func _ready():
	connectScene(curLevel)
	#saveMan.getRecentSaveSlot()
