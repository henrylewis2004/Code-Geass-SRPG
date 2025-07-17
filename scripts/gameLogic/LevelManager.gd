class_name LevelManager extends Node

@onready var curLevel : Level = get_child(0)


func resetLevel() -> void:
	var curLevelPath := curLevel.scene_file_path
	for child in get_children():
		remove_child(child)
		child.queue_free()
		
	curLevel = load(curLevelPath).instantiate()
	add_child(curLevel)
	
func nextLevel() -> void:
	var nextLevelPath: String = curLevel.getNextLevelPath()

	for child in get_children():
		remove_child(child)
		child.queue_free()
		
	curLevel = load(nextLevelPath).instantiate()
	add_child(curLevel)
	
