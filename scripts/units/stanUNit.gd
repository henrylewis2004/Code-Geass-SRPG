class_name StandardUnit extends BaseUnit

@export var moveRange: int



func getBodyPartDefences() -> Dictionary:
	return {
		"body": self.getBodyparts()[0].getDefenceType(),
		}

func isDestroyed() -> bool:
	return getBodyparts()[0].isDestroyed()

func getMoveRange() -> int:
	return min(getAp(),moveRange)

func getAbsMoveRange() -> int:
	return moveRange

func setMoveRange(newRange: int) -> void:
	moveRange = newRange

func missingArm() -> bool:
	return false
