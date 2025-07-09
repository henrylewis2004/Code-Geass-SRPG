class_name Item_abilityManager 

#signal actionComplete(endTurn: bool)
signal actionComplete(newState: int)

const CATALOGUE := preload("res://resources/scripts/enumClasses/ENUMitems_abilities.gd")
const STATE := preload("res://resources/scripts/enumClasses/ENUMstates.gd").ITEM_ABILITY_STATES
const BODYPARTS := preload("res://resources/scripts/enumClasses/ENUMbodyparts.gd").BODYPARTS

var curState: int = STATE.NONE

##getters

#items
func getItemName(itemId: int) -> String:
	match(itemId):
		CATALOGUE.items.HP_30_SINGLE:
			return "small hp"
		
	return "null"

func getItemRange(itemId: int) -> int:


	return -1

func getItemApCost(itemId: int) -> int:


	return -1

#abilities
func getAbilityName(itemId:int) -> String:

	return "null"

func getAbilityRange(itemId:int) -> int:

	return -1


func getAbilityApCost(itemId: int) -> int:


	return -1


#### methods
func itemDistUse(position1: Vector2, position2:Vector2) -> int:
	return (abs(position1.x-position2.x) + abs(position1.y-position2.y))

func heal(healAmount: int, bodyPart: BodyPart) -> void:
	bodyPart.heal(healAmount)

func validActivty(unit: BaseUnit,targetUnit:BaseUnit,activity: BaseItem) -> bool:
	if unit.getAp() < activity.getApCost():
		return false
	if activity.getRange() < itemDistUse(unit.getGridPos(),targetUnit.getGridPos()):
		return false

	return true

func validAbility(unit: BaseUnit,targetUnit:BaseUnit,ability: Ability) -> bool:
	return (validActivty(unit,targetUnit,ability) && unit.getEnergy() >= ability.getEnergyCost())


#### open core

func useItem(item:BattleItem, unit: BaseUnit, targetPart: int) -> void:
	var endTurn: bool = false

	match(item.getId()):
		CATALOGUE.items.HP_30_SINGLE:
			print("Heal")
	
	actionComplete.emit(endTurn)

func useAbility(ability: Ability, unit:BaseUnit) -> void:
	var endTurn: bool = false
	print("he")
	
	match (ability.getID()):
		CATALOGUE.abilities.MINUS_SPEED_1: 
			pass

	actionComplete.emit(endTurn)
