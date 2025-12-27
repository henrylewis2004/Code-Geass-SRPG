class_name UnitStatusScreen extends Control

const BODYPARTS := preload("res://resources/scripts/enumClasses/ENUMbodyparts.gd").BODYPARTS
const STATS := preload("res://resources/scripts/enumClasses/ENUMstats.gd").UNIT_STATS
const TYPES := preload("res://resources/scripts/enumClasses/ENUMtypes.gd").TYPES
enum PAGES{
	HP,
	WEAPONS,
	INVENTORY,
	STATS,
	}

const transparencyValue: Color = Color(1,1,1,0.5) # needs changing
const maxItems: = 3 #max items to display on inventory screen

const typeImages: Dictionary = {
	"Impact": [preload("res://assets/2d/ui/types/impactA.png"),	preload("res://assets/2d/ui/types/impactD.png")],
	"Penetration": [preload("res://assets/2d/ui/types/penetrationA.png"),preload("res://assets/2d/ui/types/penetrationD.png")], 
	"Fire": [preload("res://assets/2d/ui/types/fireA.png"),preload("res://assets/2d/ui/types/fireD.png")]}

@export var weaponTypeImg: Array[PlaceholderTexture2D] = []

@onready var top: Control = $top
@onready var topName: RichTextLabel = $top/nameLabel
@onready var topAP: RichTextLabel = $top/apLabel
@onready var topEp: RichTextLabel = $top/epLabel
@onready var topFactionName: RichTextLabel = $top/factionLabel
@onready var topCharImg: TextureRect = $top/charImg

@export_enum("page1","page2","page3","page4") var defaultPage: int = 0
@onready var pages : Array[Control] = [$page1,$page2,$page3,$page4]
@onready var pageTitles : Array[Node] = $top/pageTitles.get_children() 

var curPage: int = defaultPage


######
func getTypeImage(type:int, isAttack: bool) -> Texture:
	match (type):
		TYPES.IMPACT:
			return typeImages["Impact"][int(!isAttack)]
		TYPES.PENETRATION:
			return typeImages["Penetration"][int(!isAttack)]
		TYPES.FIRE:
			return typeImages["Fire"][int(!isAttack)]

	#error
	print("no type match??, getTypeImage, statusScreen")
	return null
	

func goToDefaultPage() -> void:
	goToPage(defaultPage)

	
func goToPage(index: int) -> void:
	for page in range(pages.size()):
		pages[page].visible = false
		pageTitles[page].modulate = transparencyValue

	pages[index].visible = true
	pageTitles[index].modulate = Color(1,1,1,1)

	curPage = index

func goToNextPage(index: int) -> void:
	var tarPage: int 
	if index > 0:
		tarPage = curPage + index if curPage + index < PAGES.size() else 0
	else:
		tarPage = curPage + index if curPage + index >= 0 else PAGES.size() - 1

	
	goToPage(tarPage)

func hideStatus() -> void:
	self.visible = false
	goToDefaultPage()

func getCurPage() -> int:
	return curPage

#update status
func updateTop(name: String, apTotal: int, ap: int,epTotal: int, ep: int, factionName: String, charImg: Texture) -> void:
	topName.text = name.replace(" ","\n")
	topAP.text = "AP: " + str(ap) + "/" + str(apTotal)
	topEp.text = "EP: " + str(ep) + "/" + str(epTotal)
	topFactionName.text = factionName
	topCharImg.texture = charImg

func updateHPData(hpRatios: Array[float],hpValues: Array[int], bodyPartTypeImg: Dictionary) -> void:
	var hpBars := pages[PAGES.HP].get_child(0).get_child(1).get_children()
	var hpNumbers := pages[PAGES.HP].get_child(0).get_child(2).get_children()
	var hpTypes := pages[PAGES.HP].get_node("hpBox/armour types")
	var hpTitles := pages[PAGES.HP].get_node("hpBox/titles")

	if hpValues.size() > 1:
		for bar in hpBars:
			bar.set_visible(true)

		for number in hpNumbers:
			number.set_visible(true)

		for type in hpTypes.get_children():
			type.set_visible(true)

		for title in hpTitles.get_children():
			title.set_visible(true)

		#update hp bars
		hpBars[0].value = hpRatios[BODYPARTS.BODY]
		hpBars[1].value = hpRatios[BODYPARTS.L_ARM]
		hpBars[2].value = hpRatios[BODYPARTS.R_ARM]
		hpBars[3].value = hpRatios[BODYPARTS.LEGS]

		#hp numbers
		hpNumbers[0].text = str(hpValues[BODYPARTS.BODY]) + "/" + str(int(hpValues[BODYPARTS.BODY] / (hpRatios[BODYPARTS.BODY] * 0.01)))
		hpNumbers[1].text = str(hpValues[BODYPARTS.L_ARM]) + "/" + str(int(hpValues[BODYPARTS.L_ARM] / (hpRatios[BODYPARTS.L_ARM] * 0.01)))
		hpNumbers[2].text = str(hpValues[BODYPARTS.R_ARM]) + "/" + str(int(hpValues[BODYPARTS.R_ARM] / (hpRatios[BODYPARTS.R_ARM] * 0.01)))
		hpNumbers[3].text = str(hpValues[BODYPARTS.LEGS]) + "/" + str(int(hpValues[BODYPARTS.LEGS] / (hpRatios[BODYPARTS.LEGS] * 0.01)))

		## body part types

		hpTypes.get_node("body").texture = bodyPartTypeImg["body"]
		hpTypes.get_node("larm").texture = bodyPartTypeImg["larm"]
		hpTypes.get_node("rarm").texture = bodyPartTypeImg["rarm"]
		hpTypes.get_node("legs").texture = bodyPartTypeImg["legs"]

	else:
		for bar in hpBars:
			bar.set_visible(false)

		for number in hpNumbers:
			number.set_visible(false)

		for type in hpTypes.get_children():
			type.set_visible(false)

		for title in hpTitles.get_children():
			title.set_visible(false)

		#update hp bars
		hpBars[0].value = hpRatios[0]
		hpBars[0].set_visible(true)
		#hp numbers
		hpNumbers[0].text = str(hpValues[0]) + "/" + str(int(hpValues[0] / (hpRatios[0] * 0.01)))
		hpNumbers[0].set_visible(true)
		## body part types
		hpTypes.get_node("body").texture = bodyPartTypeImg["body"]
		hpTypes.get_node("body").set_visible(true)
		#hp titles
		hpTitles.get_node("body").set_visible(true)



func updateWeaponData(equippedWeapon: Weapon) -> void:
	var wpnInfo := pages[PAGES.WEAPONS].get_node("weaponInfo")
	wpnInfo.get_node("typeImg").set_visible(true)

	if equippedWeapon == null:
	#	wpnInfo.get_node("weaponImg").texture = equippedWeapon.getWpnImage() #no weapon image
		wpnInfo.get_node("wpnNameLabel").text = "No Weapon Equipped" #might change to full name
		wpnInfo.get_node("dmgLabelGroup/dmgLabel").text = "No Weapon Equipped" #might change to full name
		wpnInfo.get_node("rangeLabelGroup/rangeLabel").text = "No Weapon Equipped" #might change to full name
		wpnInfo.get_node("hitLabelGroup/hitLabel").text = "No Weapon Equipped" #might change to full name
		wpnInfo.get_node("apLabelGroup/apLabel").text = "No Weapon Equipped" #might change to full name
		wpnInfo.get_node("typeImg").set_visible(false)
		return

	wpnInfo.get_node("weaponImg").texture = equippedWeapon.getWpnImage()
	wpnInfo.get_node("typeImg").texture = getTypeImage(equippedWeapon.getAttackType(),true)
	wpnInfo.get_node("wpnNameLabel").text = equippedWeapon.getName() #might change to full name
	wpnInfo.get_node("dmgLabelGroup/dmgLabel").text = str(equippedWeapon.getDmg()) + "x" + str(equippedWeapon.getRounds()) + " HIT"
	wpnInfo.get_node("rangeLabelGroup/rangeLabel").text = str(equippedWeapon.getRange()) + " TILES"
	wpnInfo.get_node("hitLabelGroup/hitLabel").text = str(equippedWeapon.getAccuracy()) + "%"
	wpnInfo.get_node("apLabelGroup/apLabel").text = str(equippedWeapon.getApCost()) + " AP"

func updateInventory(items: Array[Node], abilities: Array[Node]) -> void: #need to implement
	var invPage := pages[PAGES.INVENTORY].get_child(0)
	const tabIndent: String = "   "
	#items
	if items.size() > 0:
		var itemsList := invPage.get_node("items").get_child(1)
		invPage.get_node("items").get_child(0).text = "ITEMS:" 

		itemsList.text = ""
		for item in range(min(items.size(),maxItems)):
			itemsList.text += tabIndent + items[item].getName() + (str(items[item].getTier()) if items[item].getTier() > 1 else "") + "\n" 

	else:
		invPage.get_node("items/itemsList").text = tabIndent + "NO ITEMS"

	if abilities.size() > 0:
		var itemsList := invPage.get_node("abilities/abilitiesList")
		invPage.get_node("abilities/abilitiesTitle").text = "ABILITIES:" 

		itemsList.text = ""
		for item in range(min(abilities.size(),maxItems)):
			itemsList.text += tabIndent + abilities[item].getName() + (str(abilities[item].getTier()) if abilities[item].getTier() > 1 else "") + "\n"
	else:
		invPage.get_node("abilities/abilitiesList").text = tabIndent + "NO ABILITIES"


func updateStats(stats: Stats, moveRange: int, curMoveRange: int) -> void: #need to implement
	var statPageInfo := pages[PAGES.STATS].get_child(0)
	print(statPageInfo.name)

	for stat in STATS.size():

		if statPageInfo.get_node("stat_values").get_child(stat) is Control:
			statPageInfo.get_node("stat_values").get_child(stat).text = str(stats.getAbsStat(stat))

			if stats.getStatStatusList(stat).size() > 0:
				statPageInfo.get_node("stat_values").get_child(stat).text += " (" + str(stats.getStat(stat)) + ")"

	statPageInfo.get_node("stat_values").get_node("move_range").text = str(moveRange) 
	if curMoveRange != moveRange:
		statPageInfo.get_node("stat_values").get_node("move_range").text += " (" + str(curMoveRange) + ")"



func updateAll(unit: BaseUnit) -> void:
	updateTop(unit.getFullName(),unit.getStat(STATS.AP),unit.getAp(),unit.getStat(STATS.ENERGY),unit.getEnergy(),unit.getFactionName(),unit.getStatusImg())
	var bodyPartTypes := unit.getBodyPartDefences()
	var bodyPartTypesImg := {} 
	for part in bodyPartTypes:
		bodyPartTypesImg[part] = getTypeImage(bodyPartTypes[part], false)


	updateHPData(unit.getHP(),unit.getAbsHP(),bodyPartTypesImg)
	updateWeaponData(unit.getEquippedWeapon())
	updateInventory(unit.getItems(),unit.getAbilities())
	updateStats(unit.getStats(),unit.getAbsMoveRange(), unit.getMoveRange())
	

##
func showStatus(update: BaseUnit = null) -> void:
	if update:
		updateAll(update)
	self.visible = true
	goToDefaultPage()


#engine
func _ready() -> void:
	goToDefaultPage()
