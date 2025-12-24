class_name SaveManager

signal saveComplete

const savePathFolder: String = "res://resources/saves/saves.json"

#save data info
var saveSlot: int
var timeOfSave: String
var saveCurLevelPath: String
var dateOfSave: String

#getters
func getSaveSlot() -> int:
	return saveSlot

func getSaveTime() -> String:
	return timeOfSave

func getCurLevelPath() -> String:
	return saveCurLevelPath

func getDateOfSave() -> String:
	return dateOfSave

func getSaveSlotLevel(slot:int) -> String:
	return parseJson(savePathFolder)["slot"+str(slot+1)]["curLevel"]

func getRecentSaveSlot() -> int:
	var loadData : Dictionary = parseJson(savePathFolder)
	var slots: Array = []

	for slot in loadData:
		if loadData[slot]["curLevel"] != "":
			slots.append(slot)

	if slots.size() == 0:
		return -1 #no save

	var d: String 
	var t: String
	var s: String 
	var recentTime: int
	var highTime: int = 0

	for slot in slots:
		d = loadData[slot]["date-of-save"]
		t = loadData[slot]["time-of-save"]
		s = loadData[slot]["seconds"]
		recentTime = int(d[6]+d[7]+d[8]+d[9]+d[3]+d[4]+t.replace(":","")+s)

		if recentTime > highTime:
			highTime = recentTime
			recentTime = int(slot[4]) - 1

	return recentTime 



##
func getSaveTimes() -> Array[String]:
	var loadData = parseJson(savePathFolder)
	var times :Array[String] = []
	for slot in loadData:
		times.append(loadData[slot]["time-of-save"])

	return times

func getSaveLevels() -> Array[String]:
	var loadData = parseJson(savePathFolder)
	var levels :Array[String] = []
	for slot in loadData:
		levels.append(loadData[slot]["curLevel"])

	return levels

func getSaveDates() -> Array[String]:
	var loadData = parseJson(savePathFolder)
	var dates :Array[String] = []
	for slot in loadData:
		dates.append(loadData[slot]["date-of-save"])

	return dates

#save methods
func parseJson(path: String) -> Variant:
	var jsonText: String = FileAccess.get_file_as_string(path)
	var json = JSON.new()
	var error = json.parse(jsonText)

	if error == OK:
		var data = json.data
		if typeof(data) == TYPE_DICTIONARY:
			print("data recieved")
			return data

		else:
			print("Unexpected Data")

	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", path)
		
	return null


func writeSave(slot:int,time:String,date:String,seconds:String,curLevel:String) -> void:
	var loadData: Dictionary = parseJson(savePathFolder)
	loadData["slot" + str(slot)]["time-of-save"] = time
	loadData["slot" + str(slot)]["date-of-save"] = date
	loadData["slot" + str(slot)]["seconds"] = seconds
	loadData["slot" + str(slot)]["curLevel"] = curLevel

	var file = FileAccess.open(savePathFolder, FileAccess.WRITE)
	file.store_string(JSON.stringify(loadData))

	saveComplete.emit()

func loadSave(slot: int) -> void:
	var loadData: Dictionary = parseJson(savePathFolder)["slot" + str(slot)]

	saveSlot = slot
	timeOfSave = loadData["time-of-save"]
	saveCurLevelPath = loadData["curLevel"]
	dateOfSave = loadData["date-of-save"]

func deleteSave(saveSlot:int) -> void:
	writeSave(saveSlot,"","","","")
