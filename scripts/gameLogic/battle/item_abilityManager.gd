class_name Item_abilityManager 

signal actionComplete(ability: bool)

const CATALOGUE := preload("res://resources/scripts/enumClasses/ENUMitems_abilities.gd")
const STATS := preload("res://resources/scripts/enumClasses/ENUMstats.gd").UNIT_STATS
const BODYPARTS := preload("res://resources/scripts/enumClasses/ENUMbodyparts.gd").BODYPARTS

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

func useItem(item:BattleItem, unit: BaseUnit, targetUnit:BaseUnit, targetPart: int = BODYPARTS.BODY) -> void:

	match(item.getID()):
		CATALOGUE.ITEMS.HP_SINGLE:
			heal(30 * item.getTier(),targetUnit.getBodyparts()[targetPart])

		CATALOGUE.ITEMS.HP_ALL:
			for bodyPart in targetUnit.getBodyparts():
				heal(30 * item.getTier(),bodyPart)

		CATALOGUE.ITEMS.STATUS_CLEAN:
			targetUnit.getStats().cleanStatus()
				
	if item.isOneUse():
		unit.removeItem(item)
	
	unit.incAp(-item.getApCost())
	
	actionComplete.emit(item == Ability) #ends turn

func useAbility(ability: Ability, unit:BaseUnit,targetUnit: BaseUnit, targetPart: int = BODYPARTS.BODY) -> void:
	if ability.isAttack():
		if ability.isSinglePart():
			targetUnit.getBodyparts()[targetPart].hit(ability.getDmg())

		else:
			var bodyParts := targetUnit.getBodyparts()
			bodyParts[BODYPARTS.BODY].hit(ability.getDmg())
			bodyParts[BODYPARTS.L_ARM].hit(ability.getDmg() * 0.75)
			bodyParts[BODYPARTS.R_ARM].hit(ability.getDmg() * 0.75)
			bodyParts[BODYPARTS.LEGS].hit(ability.getDmg() * 0.5)

		for bodyPart in targetUnit.getBodyparts():
			bodyPart.hpCheck()


	if ability.addStatus():
		targetUnit.getStats().addStatus(Status.new(ability.getTier(), ability.getStatAffect(),ability.getTimeAffect()))

	unit.incAp(-ability.getApCost())
	unit.incEnergy(-ability.getEnergyCost())

	actionComplete.emit(ability == Ability)
