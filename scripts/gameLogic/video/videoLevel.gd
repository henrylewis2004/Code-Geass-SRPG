class_name VideoLevel extends Level

@export var timeSkip: float = 2.0

@onready var timer: Timer = $Timer
var skip: bool = false

func startSkip() -> void:
	skip = true
	timer.start(timeSkip)

	await timer.timeout
	if skip:
		sceneOver.emit()


func stopSkip() -> void:
	skip = false
	timer.stop()


####
func _process(delta):
	if Input.is_action_just_pressed("menu_start"):
		startSkip()

	elif Input.is_action_just_released("menu_start"):
		stopSkip()
