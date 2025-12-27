class_name BattleUnitGui extends Control

#enum
const BODYPARTS := preload("res://resources/scripts/enumClasses/ENUMbodyparts.gd").BODYPARTS
const TYPES := preload("res://resources/scripts/enumClasses/ENUMtypes.gd").TYPES

#base
@onready var baseTop = $base
@onready var base_backImage := $base/backImage as TextureRect
@onready var base_characterImage := $base/characterImage as TextureRect
@onready var base_Name := $base/nameText as RichTextLabel
@onready var base_ap := $base/apText as RichTextLabel
@onready var bodyPartsHp := $base/hp.get_children()


#expansion
@onready var expandTop := $expand
@onready var expandWeaponInfo_dmg := $expand/weaponInfo_dmg
@onready var expandWeaponInfo_range := $expand/weaponInfo_range
@onready var expandWeaponInfo_Img := $expand/weaponImg
@onready var expandWeaponInfo_Type := $expand/weaponTypeImg

const typeImages: Dictionary = {
	"Impact": preload("res://assets/2d/ui/types/impactA.png"),
	"Penetration": preload("res://assets/2d/ui/types/penetrationA.png"),
	"Fire": preload("res://assets/2d/ui/types/fireA.png")}


#methods
func getWeaponTypeImg(type: int) -> Texture:
	match(type):
		TYPES.IMPACT:
			return typeImages["Impact"]
		TYPES.PENETRATION:
			return typeImages["Penetration"]
		TYPES.FIRE:
			return typeImages["Fire"]

	return null
#base
func updateCharInfo(name: String, ap: int, characterImage: Texture) -> void:
	base_characterImage.texture = characterImage 
	base_Name.text = name.to_upper()
	base_ap.text = "AP: " + str(ap)


func updateBodyParts(bodyhp: float, lArmhp: float, rArmhp: float, legsHp: float) -> void:
	bodyPartsHp[BODYPARTS.BODY].value = bodyhp
	bodyPartsHp[BODYPARTS.L_ARM].value = lArmhp
	bodyPartsHp[BODYPARTS.R_ARM].value = rArmhp
	bodyPartsHp[BODYPARTS.LEGS].value = legsHp
	
func updateBase(name: String, ap: int, characterImage: Texture, hp: Array[float]) -> void:
	updateCharInfo(name, ap, characterImage)
	updateBodyParts(hp[BODYPARTS.BODY],hp[BODYPARTS.L_ARM],hp[BODYPARTS.R_ARM],hp[BODYPARTS.LEGS])

func hideBase() -> void:
	baseTop.set_visible(false)
	hideExpansion()
	
func showBase() -> void:
	baseTop.set_visible(true)
	


	

#expand section
func hideExpansion() -> void:
	expandTop.set_visible(false)
	
func expand() -> void:
	expandTop.set_visible(true)
	
func setExpansionInfo(equippedWeapon: Weapon) -> void:
	expandWeaponInfo_Type.set_visible(true)

	if equippedWeapon != null:
		expandWeaponInfo_dmg.text = "DMG: " + str(equippedWeapon.getDmg()) +" x " + str(equippedWeapon.getRounds())
		expandWeaponInfo_range.text = "RANGE: " + str(equippedWeapon.getRange())

		#update weapon image
		expandWeaponInfo_Type.texture = getWeaponTypeImg(equippedWeapon.getAttackType())
		expandWeaponInfo_Img.texture = equippedWeapon.getWpnImage()
		

		
	else:
		expandWeaponInfo_dmg.text = "NO WEAPON"
		expandWeaponInfo_range.text = "EQUIPPED"

		#update weapon image
		expandWeaponInfo_Type.set_visible(false)
		#
