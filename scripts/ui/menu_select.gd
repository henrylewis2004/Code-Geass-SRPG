class_name MenuSelect extends Control

signal itemSelected(item: String)

@export var menuParentPath: NodePath
@onready var menuParent := get_node(menuParentPath)
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
			itemSelected.emit(getMenuItem(selectIndex).text)

func getMenuItem(index: int) -> Control:
	if menuParent == null:
		return null
	
	if index >= menuParent.get_child_count() or index < 0:
		return null
	
	return menuParent.get_child(index) as Control

func setIndex(index: int) -> void:
	var menuItem := getMenuItem(index)

	if menuItem == null:
		return 
	
	if lastItem:
		lastItem.modulate.a = deselectOpacity
		
	lastItem = menuItem
	lastItem.modulate.a = 1
	
	selectIndex = index
	

func enable(enableSelection:bool) -> void:
	enabled = false
	setIndex(0)
	if enableSelection:
		inputTimer.start()


func _on_input_timer_timeout():
	enabled = true
