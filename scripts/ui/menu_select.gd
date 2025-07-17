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
				
			elif menuParent.get_parent().name == "items" || menuParent.get_parent().name == "abilities" || menuParent.get_parent().name == "bodyPartSelect":
				if getMenuItem(selectIndex).name == "CANCEL" || getMenuItem(selectIndex).name == "no item":
					battleItemSelected.emit(-1 - int(getMenuItem(selectIndex).name == "no item"), false)

				else:
					if menuParent.get_parent().name == "bodyPartSelect":
						partSelected.emit(selectIndex - 1)
						return

					battleItemSelected.emit(selectIndex - 1,menuParent.get_parent().name == "items")

func getMenuItem(index: int) -> Control:
	if menuParent == null:
		return null
	
	if index >= menuParent.get_child_count() or index < 1:
		return null
	
	return menuParent.get_child(index) as Control

func setIndex(index: int) -> void:
	var menuItem := getMenuItem(index)

	if menuItem == null || index == 0:
		return 
	
	if menuItem.visible == false:
		setIndex(index + (index - selectIndex))
		return
	
	
	if lastItem:
		lastItem.modulate.a = deselectOpacity
		
	lastItem = menuItem
	lastItem.modulate.a = 1
	
	selectIndex = index
	

func enable(enableSelection:bool) -> void:
	enabled = false
	setIndex(1)
	if enableSelection:
		inputTimer.start()
		
func setMenu(node: Node) -> void:
	menuParent = node



func _on_input_timer_timeout():
	enabled = true
