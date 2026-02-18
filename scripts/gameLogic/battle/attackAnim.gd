class_name AttackAnimationManager

const WEAPONID = preload("res://resources/scripts/enumClasses/ENUMweaponids.gd").WEAPONIDS


func getWeaponAnim(weapon: int) -> String:
	#needs changing
	match(weapon):
		WEAPONID.SMG:
			return "smg"
		WEAPONID.MG:
			return "mg"
		WEAPONID.RIFLE:
			return "rifle"
		WEAPONID.SNIPER:
			return "sniper"
		WEAPONID.SHOTGUN:
			return "shotgun"
		WEAPONID.PUNCH:
			return "punch"
		WEAPONID.SOLDIER_PISTOL:
			return "soldier_pistol"

	return ("err no anim")
