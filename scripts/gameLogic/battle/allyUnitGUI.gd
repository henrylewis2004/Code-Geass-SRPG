class_name AllyUnitGui extends BattleUnitGui

const ACTION_BOX_ITEM := preload("res://resources/scripts/enumClasses/ENUM_actionBoxOptions.gd").ACTION_BOX_ITEM

#weapon selection
@onready var weaponSelect := $weaponSelect
const menuItem := preload("res://scenes/game logic/menus/MenuItem.tscn")
const modulateValue : float = 0.5

#action box
@onready var actionBox := $base/MenuBox
@onready var menuSelect := $base/MenuBox/MenuSelect
const menuBoxPos: Vector2 = Vector2(11,2)

#item and abilities
@onready var itemSelectMenu := $base/MenuBox/ItemAbilitiesMenuBox/items
@onready var abilitySelectMenu := $base/MenuBox/ItemAbilitiesMenuBox/abilities
@onready var actionSelectMenu := $base/MenuBox/action

@onready var partSelectMenu := $base/MenuBox/ItemAbilitiesMenuBox/bodyPartSelect
#
const menuItemSize : int = 13
const partSelect_Xpos: Vector2 = Vector2(7,365)

#action box
func hideActionBox() -> void:
	actionSelectMenu.set_visible(false)
	menuSelect.enable(false)
	
func showActionBox(showItems: bool, showAbilities: bool) -> void:
	menuSelect.setMenu(actionSelectMenu.get_node("VBoxContainer"))

	showItem_actionBox(ACTION_BOX_ITEM.ITEMS,showItems)
	showItem_actionBox(ACTION_BOX_ITEM.ABILITY,showAbilities)

	actionSelectMenu.set_visible(true)
	menuSelect.enable(true)

	updateBoxPos(actionSelectMenu.get_node("VBoxContainer").get_children())
	
func showItem_actionBox(index: int, show: bool) -> void:
	var item : Control = menuSelect.getMenuItem(index + 1)
	if item.visible != show:
		if show:
			actionBox.position.y -= menuItemSize
		else:
			actionBox.position.y += menuItemSize 
	
	
	item.set_visible(show)

#item and abilities
func showUnitItems(items: Array[Node]) -> void:
	hideItems()
	itemSelectMenu.set_visible(true)

	populateList(items,itemSelectMenu.get_node("VBoxContainer"),"items",true)

	menuSelect.setMenu(itemSelectMenu.get_node("VBoxContainer"))
	menuSelect.enable(true)
	

func showUnitAbilities(abilities: Array[Node]) -> void:
	hideItems()
	abilitySelectMenu.set_visible(true)

	populateList(abilities,abilitySelectMenu.get_node("VBoxContainer"),"abilities",true)

	menuSelect.setMenu(abilitySelectMenu.get_node("VBoxContainer"))
	menuSelect.enable(true)

func showPartSelection(parts: Array[Node]) -> void:
	hideItems()
	partSelectMenu.set_visible(true)
	
	populateList(parts,partSelectMenu.get_node("VBoxContainer"),"parts",true)

	menuSelect.setMenu(partSelectMenu.get_node("VBoxContainer"))
	menuSelect.enable(true)
	
func partSelectPos(isPlayer: bool) -> void:
	partSelectMenu.position.x = partSelect_Xpos.x
	if isPlayer:
		partSelectMenu.position.x = partSelect_Xpos.y
	

func hideItems() -> void:
	menuSelect.enable(false)

	itemSelectMenu.set_visible(false)
	abilitySelectMenu.set_visible(false)
	actionSelectMenu.set_visible(false)
	partSelectMenu.set_visible(false)
	


func populateList(items: Array, container: Container, noneText: String,addCancel: bool) -> void:
	for item in container.get_children():
		if item.name != "topLabel":
			container.remove_child(item)
			item.queue_free()
			

	for item in items:
		var newMenuItem := menuItem.instantiate()
		newMenuItem.text = item.getName()
		var stringName: String = item.getName()

		if item is BaseItem:
			stringName = item.getName()
			
		newMenuItem.name = stringName
		container.add_child(newMenuItem)

	if items.size() <= 0:
		var newMenuItem := menuItem.instantiate()
		newMenuItem.text = "--NO " + noneText + "--"
		newMenuItem.name = "no item"
		container.add_child(newMenuItem)
		
	if addCancel:
		var newMenuItem := menuItem.instantiate()
		newMenuItem.text = "CANCEL"
		newMenuItem.name = "CANCEL"
		container.add_child(newMenuItem)

	updateBoxPos(container.get_children())

func updateBoxPos(items: Array[Node]) -> void:
	actionBox.position = menuBoxPos
	for item in items:
		if item.visible == true:
			actionBox.position.y -= menuItemSize


#weapon selection
func showWeaponSelect() -> void:
	weaponSelect.set_visible(true)

func hideWeaponSelect() -> void:
	weaponSelect.set_visible(false)

func updateWeaponSelect(weapons: Array[Node]) -> void:
	var weaponList := $weaponSelect/weaponsBox
	populateList(weapons,weaponList,"weapons",false)

		
func selectWeapon(index: int) -> void:
	var weaponList := $weaponSelect/weaponsBox.get_children()
	for weapon in weaponList:
		weapon.modulate.a = 0.5
	
	weaponList[0].modulate.a = 1
	weaponList[index + 1].modulate.a = 1


func showStatus() -> void:
	print("status")
