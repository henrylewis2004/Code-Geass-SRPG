class_name Item_abilityManager 

signal actionComplete(ability: bool)

const CATALOGUE := preload("res://resources/scripts/enumClasses/ENUMitems_abilities.gd")
const STATS := preload("res://resources/scripts/enumClasses/ENUMstats.gd").UNIT_STATS
const BODYPARTS := preload("res://resources/scripts/enumClasses/ENUMbodyparts.gd").BODYPARTS

var animPlayer: AnimationPlayer

####
func _init(animPlayer: AnimationPlayer) -> void:
	self.animPlayer = animPlayer

func end_animation(ability: bool) -> void:
	var anim: String = "itemAnim" #item
	if ability:
		anim = "geassAnim"	#ability

	animPlayer.play(anim)


func attackBody_only(abilityID: int) -> bool:
	if abilityID == CATALOGUE.ABILITIES.SLASH_HARKEN:
		return true
	return false

func getItemTimeCost(item: int) -> int:
	match(item):
		CATALOGUE.ITEMS.HP_SINGLE:
			return 10
		CATALOGUE.ITEMS.HP_ALL:
			return 12
		CATALOGUE.ITEMS.STATUS_CLEAN:
			return 12

func getAbilityTimeCost(item: int) -> int:
	match(item):
		CATALOGUE.ABILITIES.MINUS_SPEED
			return 10
		CATALOGUE.ABILITIES.SLASH_HARKEN
			return 12


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
	end_animation(false)
	await animPlayer.animation_finished

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
	
	actionComplete.emit(false) #ends turn

func useAbility(ability: Ability, unit:BaseUnit,targetUnit: BaseUnit, targetPart: int = BODYPARTS.BODY) -> void:
	end_animation(true)
	await animPlayer.animation_finished

	if ability.isAttack():
		if attackBody_only(ability.getID()) || targetUnit is StandardUnit:
			var tarPart: int = 0 if targetUnit is StandardUnit else BODYPARTS.BODY
			targetUnit.getBodyparts()[tarPart].hit(ability.getDmg())
		
		elif ability.isSinglePart():
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

	if ability.hasBonusAffect():
		match(ability.getID()):
			CATALOGUE.ABILITIES.SLASH_HARKEN:
				#move unit to next to attack unit
				var posDif: Vector2 = unit.getGridPos() - targetUnit.getGridPos()
				if posDif.x == 0:
					unit.setGridPos(Vector2(unit.getGridPos().x, targetUnit.getGridPos().y + 1 if posDif.y > 0 else targetUnit.getGridPos().y - 1))
				elif posDif.y == 0:
					unit.setGridPos(Vector2(targetUnit.getGridPos().x + 1 if posDif.x > 0 else targetUnit.getGridPos().x - 1, unit.getGridPos().y))
				else:
					unit.setGridPos(Vector2(targetUnit.getGridPos().x + 1 if posDif.x > 0 else targetUnit.getGridPos().x - 1, targetUnit.getGridPos().y + 1 if posDif.y > 0 else targetUnit.getGridPos().y - 1))

	unit.incAp(-ability.getApCost())
	unit.incEnergy(-ability.getEnergyCost())

	actionComplete.emit(true)
