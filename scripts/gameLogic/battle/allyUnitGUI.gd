class_name AllyUnitGui extends BattleUnitGui

#action box
@onready var actionBox := $base/MenuBox
@onready var menuSelect := $base/MenuBox/MenuSelect


#action box
func hideActionBox() -> void:
	actionBox.set_visible(false)
	menuSelect.enable(false)
	
func showActionBox() -> void:
	actionBox.set_visible(true)
	menuSelect.enable(true)