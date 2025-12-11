class_name Status

var powerAffect: int = 0
var statAffect: int
var timeAffect: int = -1 #-1 = permament
var curTimeAffect: int


func getPower() -> int:
	return powerAffect

func getStat() -> int:
	return statAffect

func getTimeLeft() -> int:
	return curTimeAffect

func getTotalTime() -> int:
	return timeAffect
#init
func _init(power: int, stat: int, time: int, startTime: int = null) -> void:
	statAffect = stat
	timeAffect = time
	curTimeAffect = timeAffect
	if startTime:
		curTimeAffect = startTime
	powerAffect = power

