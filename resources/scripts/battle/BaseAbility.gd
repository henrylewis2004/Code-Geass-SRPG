class_name Ability extends BaseItem 

@export_enum(
	"MINUS_SPEED_1",
	) var battleId: int
	

@export var attack: bool
@export var targetEnemy: bool
@export var energyCost: int

#getter setters
func getID() -> int:
	return battleId

func isAttack() -> bool:
	return attack

func getTargetEnemy() -> bool:
	return targetEnemy

func getEnergyCost() -> int:
	return energyCost