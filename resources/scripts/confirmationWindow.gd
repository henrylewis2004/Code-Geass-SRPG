class_name ConfirmationWindow extends Control

signal confirm(confirm: bool)

var selectedIndex: int = 0
const deselectOpacity: float = 0.5

#menu options
@onready var menuItems := $options.get_children()


## engine

func _ready():
	set_process(false)
	menuItems[selectedIndex].modulate.a = 1

func _process(delta):
#	print("here")
	if Input.is_action_just_pressed("left") || Input.is_action_just_pressed("right"):
		var input: int = Input.get_axis("left","right")

		menuItems[selectedIndex].modulate.a = deselectOpacity
		selectedIndex += input

		if selectedIndex < 0:
			selectedIndex = menuItems.size() - 1 
		elif selectedIndex > menuItems.size() - 1:
			selectedIndex = 0
			
		menuItems[selectedIndex].modulate.a = 1
			

	if Input.is_action_just_pressed("accept"):
		confirm.emit(selectedIndex == 1)
	
	elif Input.is_action_just_pressed("cancel"):
		confirm.emit(false)


func _on_timer_timeout():
	set_process(true)
