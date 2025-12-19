class_name typeManager

const TYPES := preload("res://resources/scripts/enumClasses/ENUMtypes.gd").TYPES

const resValue: float = 0.5
const bonusValue: float = 1.5
const defValue: float = 1.0

##
func getTypeAffectAttack(attackType: int, defenceType: int) -> float:
	if attackType == defenceType:
		return defValue

	match attackType:
		TYPES.IMPACT:
			match defenceType:
				TYPES.FIRE:
					return bonusValue
				TYPES.IMPACT:
					return resValue
				
		TYPES.PENETRATION:
			match defenceType:
				TYPES.IMPACT:
					return bonusValue
				TYPES.PENETRATION:
					return resValue

		TYPES.FIRE:
			match defenceType:
				TYPES.PENETRATION:
					return bonusValue
				TYPES.FIRE:
					return resValue

	return defValue

