class_name LegsBodypart extends BodyPart

@export var moveRange: int

func getMoveRange() -> int:
	return moveRange

func setMoveRange(moveRng: int) -> void:
	moveRange = moveRng

#methods
func destroy():
	moveRange = 1
	destroyed = true


#engine
func _ready():
	bodyPartType = BODYPARTS.LEGS
	hp = totalHp
