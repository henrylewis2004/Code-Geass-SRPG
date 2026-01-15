class_name VideoLevel extends Level

@export var timeSkip: float = 2.0

@onready var timer: Timer = $Timer
@onready var skipAnimPlayer: AnimationPlayer = $SkipAnimation.get_node("AnimationPlayer")
var skip: bool = false

func startSkip() -> void:
	skip = true
	timer.start(timeSkip)
	skipAnimPlayer.play("skip")

	await timer.timeout
	if skip:
		set_process(false)
		skipAnimPlayer.play("endSkip")
		await skipAnimPlayer.animation_finished
		sceneOver.emit()



func stopSkip() -> void:
	skip = false
	skipAnimPlayer.play("RESET")
	timer.stop()


####
func _process(delta):
	if Input.is_action_just_pressed("menu_start"):
		startSkip()

	elif Input.is_action_just_released("menu_start"):
		stopSkip()
