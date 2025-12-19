class_name Status

var powerAffect: int  #strength of affect
var statAffect: int  #stat affected
var timeAffect: int  #length of affect; -1 = permament
var curTimeAffect: int #how long the affect will be active for


#getters
func getPower() -> int:
	return powerAffect

func getStat() -> int:
	return statAffect

func getTimeLeft() -> int:
	return curTimeAffect

func getTotalTime() -> int:
	return timeAffect

#setters
func incTime(val: int) -> void:
	curTimeAffect += val

#init
func _init(power: int, stat: int, time: int, startTime: int = -1) -> void:
	statAffect = stat
	timeAffect = time
	curTimeAffect = timeAffect
	if startTime >= 0:
		curTimeAffect = startTime
	powerAffect = power
