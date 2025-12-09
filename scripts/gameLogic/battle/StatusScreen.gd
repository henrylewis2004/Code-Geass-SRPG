class_name UnitStatusScreen extends Control

const BODYPARTS := preload("res://resources/scripts/enumClasses/ENUMbodyparts.gd").BODYPARTS
const STATS := preload("res://resources/scripts/enumClasses/ENUMstats.gd").UNIT_STATS
enum PAGES{
	HP,
	WEAPONS,
	INVENTORY,
	STATS,
	}

const transparencyValue: Color = Color(1,1,1,0.5) # needs changing

@export var weaponTypeImg: Array[PlaceholderTexture2D] = []

@onready var top: Control = $top
@onready var topName: RichTextLabel = $top/nameLabel
@onready var topAP: RichTextLabel = $top/apLabel
@onready var topFactionName: RichTextLabel = $top/factionLabel
@onready var topCharImg: TextureRect = $top/charImg

@export_enum("page1","page2","page3","page4") var defaultPage: int = 0
@onready var pages : Array[Control] = [$page1,$page2,$page3,$page4]
@onready var pageTitles : Array[Node] = $top/pageTitles.get_children() 

var curPage: int = defaultPage


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
func updateTop(name: String, apTotal: int, ap: int, factionName: String, charImg: Texture) -> void:
	topName.text = name.replace(" ","\n")
	topAP.text = "AP: " + str(ap) + "/" + str(apTotal)
	topFactionName.text = factionName
	topCharImg.texture = charImg

func updateHPData(hpRatios: Array[float],hpValues: Array[int]) -> void:
	#update hp bars
	var hpBars := pages[PAGES.HP].get_child(0).get_child(1).get_children()
	
	hpBars[0].value = hpRatios[BODYPARTS.BODY]
	hpBars[1].value = hpRatios[BODYPARTS.L_ARM]
	hpBars[2].value = hpRatios[BODYPARTS.R_ARM]
	hpBars[3].value = hpRatios[BODYPARTS.LEGS]

	var hpNumbers := pages[PAGES.HP].get_child(0).get_child(2).get_children()

	hpNumbers[0].text = str(hpValues[BODYPARTS.BODY]) + "/" + str(int(hpValues[BODYPARTS.BODY] / (hpRatios[BODYPARTS.BODY] * 0.01)))
	hpNumbers[1].text = str(hpValues[BODYPARTS.L_ARM]) + "/" + str(int(hpValues[BODYPARTS.L_ARM] / (hpRatios[BODYPARTS.L_ARM] * 0.01)))
	hpNumbers[2].text = str(hpValues[BODYPARTS.R_ARM]) + "/" + str(int(hpValues[BODYPARTS.R_ARM] / (hpRatios[BODYPARTS.R_ARM] * 0.01)))
	hpNumbers[3].text = str(hpValues[BODYPARTS.LEGS]) + "/" + str(int(hpValues[BODYPARTS.LEGS] / (hpRatios[BODYPARTS.LEGS] * 0.01)))

func updateWeaponData(equippedWeapon: Weapon) -> void:
	var wpnInfo := pages[PAGES.WEAPONS].get_child(0)

	wpnInfo.get_child(0).texture = equippedWeapon.getWpnImage()
	wpnInfo.get_child(1).text = equippedWeapon.getName() #might change to full name
	wpnInfo.get_child(2).get_child(1).text = str(equippedWeapon.getDmg()) + "x" + str(equippedWeapon.getRounds()) + " HIT"
	wpnInfo.get_child(3).get_child(1).text = str(equippedWeapon.getRange()) + " TILES"
	wpnInfo.get_child(4).get_child(1).text = str(equippedWeapon.getAccuracy()) + "%"
	wpnInfo.get_child(5).get_child(1).text = str(equippedWeapon.getApCost()) + " AP"

func updateInventory(items: Array[Node], abilities: Array[Node]) -> void: #need to implement
	var invPage := pages[PAGES.INVENTORY].get_child(0)
	const maxItems: = 5
	const tabIndent: String = "   "
	#items
	if items.size() > 0:
		var itemsList := invPage.get_node("items").get_child(0)
		itemsList.text = "ITEMS:"
		for item in range(maxItems):
			itemsList.text += "\n" + tabIndent + items[item].getName()
	else:
		invPage.get_node("items").get_child(0).text += "\n" + tabIndent + "NO ITEMS"

	if abilities.size() > 0:
		var itemsList := invPage.get_node("abilities").get_child(0)
		itemsList.text = "ABILITIES:"
		for item in range(maxItems):
			itemsList.text += "\n" + tabIndent + abilities[item].getName()
	else:
		invPage.get_node("items").get_child(0).text += "\n" + tabIndent + "NO ABILITIES"


func updateStats(stats: Stats) -> void: #need to implement
	var statPage := pages[PAGES.STATS].get_child(0)

	for stat in statPage.get_children().size():
		if statPage.get_child(stat) is Control:
			statPage.get_child(stat).get_child(1).text = str(stats.getAbsStat(stat))
			if stats.getStatStatusList(stat).size() > 0:
				statPage.get_child(stat).get_child(1).text += "(" + str(stats.getStat(stat)) + ")"



func updateAll(unit: BaseUnit) -> void:
	updateTop(unit.getFullName(),unit.getStat(STATS.AP),unit.getAp(),unit.getFactionName(),unit.getStatusImg())
	updateHPData(unit.getHP(),unit.getAbsHP())
	updateWeaponData(unit.getEquippedWeapon())
	#updateInventory(unit.getItems(),unit.getAbilities())
	updateStats(unit.getStats())
	

##
func showStatus() -> void:
	self.visible = true
	goToDefaultPage()


#engine
func _ready() -> void:
	goToDefaultPage()
