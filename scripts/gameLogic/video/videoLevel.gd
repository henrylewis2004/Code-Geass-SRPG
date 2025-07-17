class_name VideoLevel extends Level

func _process(delta):
    if Input.is_action_just_pressed("menu_start"):
        sceneOver.emit()
