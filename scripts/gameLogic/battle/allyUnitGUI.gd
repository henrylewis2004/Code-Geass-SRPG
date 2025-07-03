class_name AllyUnitGui extends BattleUnitGui

#action box
@onready var actionBox := $base/MenuBox
@onready var menuSelect := $base/MenuBox/MenuSelect

#weapon selection
@onready var weaponSelect := $weaponSelect
const weaponItem := preload("res://scenes/game logic/menus/MenuItem.tscn")
const modulateValue : float = 0.5

#
const menuItemSize : int = 13

#action box
func hideActionBox() -> void:
	actionBox.set_visible(false)
	menuSelect.enable(false)
	
func showActionBox() -> void:
	actionBox.set_visible(true)
	menuSelect.enable(true)
	
func showItem_actionBox(index: int, show: bool) -> void:
	var item : Control = menuSelect.getMenuItem(index)
	if item.visible != show:
		if show:
			actionBox.position.y -= menuItemSize
		else:
			actionBox.position.y += menuItemSize 
	
	
	item.set_visible(show)


#weapon selection
func showWeaponSelect() -> void:
	weaponSelect.set_visible(true)

func hideWeaponSelect() -> void:
	weaponSelect.set_visible(false)

func updateWeaponSelect(weapons: Array[Node]) -> void:
	var weaponList := $weaponSelect/weaponsBox

	if weaponList.get_children().size() > 0:
		for weapon in weaponList.get_children():
			if weapon.name != "weaponsTop":
				weaponList.remove_child(weapon)
				weapon.queue_free()
	
	for weapon in weapons:
		var weaponLabel := weaponItem.instantiate()
		weaponLabel.text = weapon.getName()
		weaponList.add_child(weaponLabel)
		
func selectWeapon(index: int) -> void:
	var weaponList := $weaponSelect/weaponsBox.get_children()
	for weapon in weaponList:
		weapon.modulate.a = 0.5
	
	weaponList[0].modulate.a = 1
	weaponList[index + 1].modulate.a = 1
