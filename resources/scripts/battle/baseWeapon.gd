class_name Weapon extends Node

@export var dmg: int
@export var string_name: String
@export var accuracy: int
@export var rounds: int
@export var twoHanded: bool
@export var apCost: int
@export var equipPart: BodyPart
@export var range: int
@export var fireRate: float
@export var wpnImage: Texture

#getters
func getDmg() -> int:
	return dmg

func getWpnImage() -> Texture:
	return wpnImage

func getName() -> String:
	return string_name

func getAccuracy() -> int:
	return accuracy

func getRounds() -> int:
	return rounds

func getRange() -> int:
	return range

func getApCost() -> int:
	return apCost

func isTwoHanded() -> bool:
	return twoHanded

func getEquipPart() -> BodyPart:
	return equipPart

func getWeaponFireRate() -> float:
	return fireRate

func getWpnInfo() -> Array:
	return [dmg,string_name,accuracy,rounds, range, apCost]


#methods
func hit() -> bool: #need to add two handed debuff
	var hitInt: int = randi() % 101
	if (hitInt < accuracy):
		return true
	return false

func dmgCalc(twoHanded_debuff: bool,unit: BaseUnit,targetUnit:BaseUnit,unitPos:Vector2 = unit.getGridPos()) -> int:
	var wpnAcc : int = accuracy
	if twoHanded_debuff: wpnAcc = wpnAcc / 2
	
	return (dmg * float(wpnAcc)/100 * rounds)


	
