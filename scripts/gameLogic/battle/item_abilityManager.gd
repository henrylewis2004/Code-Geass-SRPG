class_name Item_abilityManager 

#signal actionComplete(endTurn: bool)
signal actionComplete(endTurn: bool)

const CATALOGUE := preload("res://resources/scripts/enumClasses/ENUMitems_abilities.gd")
const STATE_BATTLE := preload("res://resources/scripts/enumClasses/ENUMstates.gd").BATTLESTATE
const STATE := preload("res://resources/scripts/enumClasses/ENUMstates.gd").ITEM_ABILITY_STATES
const BODYPARTS := preload("res://resources/scripts/enumClasses/ENUMbodyparts.gd").BODYPARTS

var curState: int = STATE.NONE


#### methods
func itemDistUse(position1: Vector2, position2:Vector2) -> int:
	return (abs(position1.x-position2.x) + abs(position1.y-position2.y))

func heal(healAmount: int, bodyPart: BodyPart) -> void:
	bodyPart.heal(healAmount)

func validItem(unit: BaseUnit,targetUnit:BaseUnit,activity: BaseItem) -> bool:
	if unit.getAp() < activity.getApCost():
		return false
	if activity.getRange() < itemDistUse(unit.getGridPos(),targetUnit.getGridPos()):
		return false

	return true

func validAbility(unit: BaseUnit,targetUnit:BaseUnit,ability: Ability) -> bool:
	return (validItem(unit,targetUnit,ability) && unit.getEnergy() >= ability.getEnergyCost())

func validActivity(unit: BaseUnit,targetUnit:BaseUnit,activity: BaseItem) -> bool:
	if activity is Ability:
		return validAbility(unit,targetUnit,activity)
	else:
		return validItem(unit,targetUnit,activity)
	

#### open core

func useItem(item:BattleItem, unit: BaseUnit, targetUnit:BaseUnit, targetPart: int = -1) -> void:
	var endTurn: bool = true
	print(targetPart)

	match(item.getID()):
		CATALOGUE.items.HP_30_SINGLE:
			print("Heal")
	
	actionComplete.emit(endTurn)

func useAbility(ability: Ability, unit:BaseUnit,targetUnit: BaseUnit) -> void:
	var endTurn: bool = true
	
	match (ability.getID()):
		CATALOGUE.abilities.MINUS_SPEED_1: 
			pass

	actionComplete.emit(endTurn)
