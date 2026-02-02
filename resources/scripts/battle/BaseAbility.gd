class_name Ability extends BaseItem 

	

@export_enum("agility", "defence", "evasion", "melee", "ranged", "ap", "ap_charge", "energy", "energy_charge", "luck", "INITIATIVE") var statAffect: int

@export_enum(
	"MINUS_SPEED", 
	"SLASH_HARKEN",
) var id:int

var attackId := preload("res://resources/scripts/enumClasses/ENUMitems_abilities.gd").TYPEID.ATTACK
@export var targetEnemy: bool
@export var energyCost: int
@export var timeAffect: int = 1
@export var dmg: int
@export var debuf: bool 
@export var status: bool = true

@export var bonusAffect: bool = true

#getter setters
func getID() -> int:
	return id
	
func hasBonusAffect() -> bool:
	return bonusAffect

func getStatAffect() -> int:
	return statAffect

func getTier() -> int:
	return tier * -1 if debuf else tier

func getDmg() -> int:
	return dmg

func isAttack() -> bool:
	return itemType == attackId

func addStatus() -> bool:
	return status

func getTargetEnemy() -> bool:
	return targetEnemy

func getEnergyCost() -> int:
	return energyCost

func getTimeAffect() -> int:
	return timeAffect
