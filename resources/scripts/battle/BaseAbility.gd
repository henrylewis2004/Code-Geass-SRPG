class_name Ability extends BaseItem 

@export_enum(
	"MINUS_SPEED",
	) var battleId: int
	

var attackId := preload("res://resources/scripts/enumClasses/ENUMitems_abilities.gd").TYPEID.ATTACK
@export var targetEnemy: bool
@export var energyCost: int
@export var timeAffect: int = 1
@export var dmg: int
@export var status: bool = true

#getter setters
func getID() -> int:
	return battleId

func getDmg() -> int:
	return dmg

func isAttack() -> bool:
	return itemType == attackId

func isStatus() -> bool:
	return status

func getTargetEnemy() -> bool:
	return targetEnemy

func getEnergyCost() -> int:
	return energyCost

func getTimeAffect() -> int:
	return timeAffect
