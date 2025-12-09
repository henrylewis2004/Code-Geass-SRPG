class_name PlayerController

@export var gridPos: Vector2 = Vector2i(4,7)

func getGridPos() -> Vector2:
	return gridPos

func movement(input: Vector2) -> void:
	if gridPos.x + input.round().x >= 0 && gridPos.x + input.round().x < 8:
		if gridPos.y + input.round().y >= 0 && gridPos.y + input.round().y < 8:
			gridPos += input.round()

###
func _init(team: int) -> void:
	gridPos = Vector2(4 - team, 7)

