class_name MenuSelect extends Control

signal itemSelected(item: String)
signal battleItemSelected(itemKey: int,isItem:bool)
signal partSelected(partId: int)

@export var menuParent: Node
@onready var inputTimer := $inputTimer

const deselectOpacity: float = 0.5
var selectIndex: int = 0
var lastItem: Label

var enabled: bool = false
@export var enabledShadow_text: bool = false

#methods
func _process(delta):
	var input: Vector2 = Vector2.ZERO

	if enabled:
		input.y = int(Input.is_action_just_pressed("down")) - int(Input.is_action_just_pressed("up"))
		input.x = int(Input.is_action_just_pressed("right")) - int(Input.is_action_just_pressed("left"))
		
		match (menuParent.get_class()):
			"VBoxContainer":
				setIndex(selectIndex + input.y)
			"HBoxContainer":
				setIndex(selectIndex + input.x)
			"GridContainer":
				setIndex(selectIndex + input.y + input.x * menuParent.columns)
		
		if Input.is_action_just_pressed("accept"):
			if menuParent.get_parent().name == "action": 
				itemSelected.emit(getMenuItem(selectIndex).text)
				
			if menuParent.get_parent().name == "items" || menuParent.get_parent().name == "abilities" || menuParent.get_parent().name == "bodyPartSelect":
				if getMenuItem(selectIndex).name == "CANCEL" || getMenuItem(selectIndex).name == "no item":
					battleItemSelected.emit(-1 - int(getMenuItem(selectIndex).name == "no item"), false)

				else:
					if menuParent.get_parent().name == "bodyPartSelect":
						partSelected.emit(selectIndex - 1)
						return

					battleItemSelected.emit(selectIndex - 1,menuParent.get_parent().name == "items")
			else: #unique selection
				itemSelected.emit(getMenuItem(selectIndex).name)

func getMenuItem(index: int) -> Control:
	if menuParent == null:
		return null
	
	if index >= menuParent.get_child_count() || index < 0 || (index == 0 && menuParent.get_child(index).name == "topLabel"):
		return null
	
	return menuParent.get_child(index) as Control

func setIndex(index: int) -> void:
	var menuItem := getMenuItem(index)

	if menuItem == null :
		return 
	
	if menuItem.visible == false:
		setIndex(index + (index - selectIndex))
		return
	
	
	if lastItem:
		lastItem.modulate.a = deselectOpacity
		if enabledShadow_text:
			lastItem.remove_theme_color_override("font_shadow_color")
			
		
		
	lastItem = menuItem
	lastItem.modulate.a = 1

	if enabledShadow_text:
		lastItem.add_theme_color_override("font_shadow_color",Color.BLACK)
	
	selectIndex = index
	
func enableShadow(shadow: bool) -> void:
	enabledShadow_text = shadow

func enable(enableSelection:bool) -> void:
	enabled = false

	if lastItem:
		lastItem.modulate.a = deselectOpacity
		if enabledShadow_text:
			lastItem.remove_theme_color_override("font_shadow_color")


	if enableSelection:
		setIndex(1)
		if menuParent.get_child(0).name != "topLabel":
			setIndex(0)
		inputTimer.start()
		
func setMenu(node: Node) -> void:
	menuParent = node



func _on_input_timer_timeout():
	enabled = true
