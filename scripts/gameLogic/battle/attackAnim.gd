class_name AttackAnimationManager

const WEAPONID = preload("res://resources/scripts/enumClasses/ENUMweaponids.gd").WEAPONIDS


func getWeaponAnim(weapon: int) -> String:
	#needs changing
	match(weapon):
		WEAPONID.SMG:
			return "SMG"
		WEAPONID.MG:
			return "MG"
		WEAPONID.RIFLE:
			return "RIFLE"
		WEAPONID.SNIPER:
			return "SNIPER"
		WEAPONID.SHOTGUN:
			return "SHOTGUN"
		WEAPONID.PUNCH:
			return "PUNCH"
		WEAPONID.SOLDIER_PISTOL:
			return "SOLDIER_PISTOL"

	return ("err no anim")
