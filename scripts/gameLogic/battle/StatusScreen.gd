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
	
	hpBars[0].progress = hpRatios[BODYPARTS.BODY]
	hpBars[1].progress = hpRatios[BODYPARTS.L_ARM]
	hpBars[2].progress = hpRatios[BODYPARTS.R_ARM]
	hpBars[3].progress = hpRatios[BODYPARTS.LEGS]

	var hpNumbers := pages[PAGES.HP].get_child(0).get_child(2).get_children()

	hpNumbers[0].text = str(hpValues[BODYPARTS.BODY]) + "/" + str(hpValues[BODYPARTS.BODY] * hpRatios[BODYPARTS.BODY])
	hpNumbers[1].text = str(hpValues[BODYPARTS.L_ARM]) + "/" + str(hpValues[BODYPARTS.L_ARM] * hpRatios[BODYPARTS.L_ARM])
	hpNumbers[2].text = str(hpValues[BODYPARTS.R_ARM]) + "/" + str(hpValues[BODYPARTS.R_ARM] * hpRatios[BODYPARTS.R_ARM])
	hpNumbers[3].text = str(hpValues[BODYPARTS.LEGS]) + "/" + str(hpValues[BODYPARTS.LEGS] * hpRatios[BODYPARTS.LEGS])

func updateWeaponData(equippedWeapon: Weapon) -> void:
	var wpnInfo := pages[PAGES.WEAPONS].get_child(0)

	wpnInfo.get_child(0).texture = equippedWeapon.getWpnImage()
	wpnInfo.get_child(1).text = equippedWeapon.getName() #might change to full name
	wpnInfo.get_child(2).get_child(1).text = str(equippedWeapon.getDmg()) + "x" + str(equippedWeapon.getRounds()) + "HIT"
	wpnInfo.get_child(3).get_child(1).text = str(equippedWeapon.getRange()) + "TILES"
	wpnInfo.get_child(4).get_child(1).text = str(equippedWeapon.getAccuracy()) + "%"
	wpnInfo.get_child(5).get_child(1).text = str(equippedWeapon.getApCost()) + "AP"

func updateInventory() -> void: #need to implement
	pass

func updateStats(stats: Stats) -> void: #need to implement
	pass

func updateAll(unit: BaseUnit) -> void:
	#updateTop()
	#updateHPData()
	#updateWeaponData()
	#updateInventory()
	#updateStats()
	pass
	

##
func showStatus() -> void:
	self.visible = true
	goToDefaultPage()


#engine
func _ready() -> void:
	goToDefaultPage()
