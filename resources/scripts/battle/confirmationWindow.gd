class_name ConfirmationWindow extends Control

signal confirm(confirm: bool)

var selectedIndex: int = 0
const deselectOpacity: float = 0.5

#menu options
@onready var menuItems := $VBoxContainer/options.get_children()
@export var shadowText: bool = false

func setPos(newPosition: Vector2) -> void:
	position = newPosition

func setTopLabel(text: String) -> void:
	var topLabel: Label = $VBoxContainer.get_child(0)
	topLabel.text = text
	
func getWindowSize() -> Vector2:
	return $VBoxContainer.size

## engine

func _ready():
	set_process(false)
	menuItems[selectedIndex].modulate.a = 1
	if shadowText:
		menuItems[selectedIndex].add_theme_color_override("font_shadow_color",Color.BLACK)

func _process(delta):
#	print("here")
	if Input.is_action_just_pressed("left") || Input.is_action_just_pressed("right"):
		var input: int = Input.get_axis("left","right")

		menuItems[selectedIndex].modulate.a = deselectOpacity
		if shadowText:
			menuItems[selectedIndex].remove_theme_color_override("font_shadow_color")
		selectedIndex += input

		if selectedIndex < 0:
			selectedIndex = menuItems.size() - 1 
		elif selectedIndex > menuItems.size() - 1:
			selectedIndex = 0
			
		menuItems[selectedIndex].modulate.a = 1
		if shadowText:
			menuItems[selectedIndex].add_theme_color_override("font_shadow_color",Color.BLACK)
			

	if Input.is_action_just_pressed("accept"):
		confirm.emit(selectedIndex == 1)
	
	elif Input.is_action_just_pressed("cancel"):
		confirm.emit(false)


func _on_timer_timeout():
	set_process(true)
