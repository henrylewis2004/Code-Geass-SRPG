class_name AllyUnitGui extends BattleUnitGui

#action box
@onready var actionBox := $base/MenuBox
@onready var menuSelect := $base/MenuBox/MenuSelect


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
