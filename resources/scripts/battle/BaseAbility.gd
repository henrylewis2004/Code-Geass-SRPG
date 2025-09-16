class_name Ability extends BaseItem 

@export_enum(
	"MINUS_SPEED_1",
	) var battleId: int
	

var attackId := preload("res://resources/scripts/enumClasses/ENUMitems_abilities.gd").typeID.ATTACK
@export var targetEnemy: bool
@export var energyCost: int

#getter setters
func getID() -> int:
	return battleId

func isAttack() -> bool:
	return itemType == attackId

func getTargetEnemy() -> bool:
	return targetEnemy

func getEnergyCost() -> int:
	return energyCost