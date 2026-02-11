class_name LevelManager extends Node

signal loaded

const saveRoomScene := preload("res://scenes/levels/menu/saveRoom.tscn")
@onready var loadingScreen := $LoadingScreen

@onready var curLevel : Level = get_child(1)
var saveMan: SaveManager = SaveManager.new()

func connectScene(scene:Level) -> void:
	scene.resetScene.connect(resetLevel)
	scene.sceneOver.connect(nextLevel)
	
	if scene is MainMenu:
		scene.continueGame.connect(loadRecentSave)
		scene.loadSlot.connect(loadSaveSlot)
		scene.refreshSaveSlots.connect(updateMenuSlot)
		scene.deleteSlot.connect(deleteSlot)

	curLevel.start()

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
		if child != loadingScreen:
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
	if levelPath != "":
		var saveRoom: bool = level.toSaveRoom()
		var previousLevel := get_children()

		ResourceLoader.load_threaded_request(levelPath)

		if level.toLoadingScreen():
			loadingScreen.set_visible(true)
			loadingScreen.get_node("loadingMusic").play()
			var loadingTimer: Timer = loadingScreen.get_node("progressTimer")
			var loadingBar: TextureProgressBar = loadingScreen.get_node("progressbar")

			loadingBar.value = 0
			loadingTimer.connect("timeout",load_timeout.bind(loadingTimer,loadingBar,levelPath))

			load_timeout(loadingTimer,loadingBar,levelPath)
		

		for child in previousLevel:
			if child != loadingScreen:
				remove_child(child)
				child.queue_free()

		if level.toLoadingScreen():
			await loaded
			loadingScreen.get_node("loadingMusic").stop()
			loadingScreen.set_visible(false)

		var nextLevel_Scene := ResourceLoader.load_threaded_get(levelPath)
		curLevel = nextLevel_Scene.instantiate() if !saveRoom else saveRoomScene.instantiate() 

		if saveRoom:
			curLevel.setNextLevel(levelPath)
			curLevel.exitToMenu.connect(goToMenu)
			curLevel.saveChosen.connect(findSaveSlot)

			curLevel.setToLoadingScreen(level.toLoadingScreen())

		add_child(curLevel)
		connectScene(curLevel)



	
func nextLevel() -> void:
	var nextLevelPath: String = curLevel.getNextLevelPath()
	loadLevel(nextLevelPath)
	
	
func load_timeout(timer:Timer,progressbar:TextureProgressBar,levelPath:String) -> void:
	var progress: Array = []
	var load_status := ResourceLoader.load_threaded_get_status(levelPath,progress)
	var progressValue : float = progress[0] * 100

	if load_status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
		progressbar.value = progressValue
		loaded.emit()
		return

	if load_status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_FAILED || load_status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_INVALID_RESOURCE:
		#might need to further implement ?
		print("loading failed")
		return

	if load_status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
		progressbar.value = progressValue
		timer.start()
		
	
	
#engine
func _ready():
	connectScene(curLevel)
	saveMan.getRecentSaveSlot()
