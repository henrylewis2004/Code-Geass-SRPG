class_name ChessDrawManager extends Node2D

var playerPosRect: Rect2 = Rect2(0,0,0,0)

# player
func updatePlayerPos(pos: Vector2, cellSize: Vector2, startLoc: Vector2) -> void:
	pos = pos * cellSize + startLoc
	playerPosRect = Rect2(pos,cellSize)

	queue_redraw()

func clearPlayerRect() -> void:
	playerPosRect = Rect2(0,0,0,0)
	queue_redraw()


func _draw() -> void:
	draw_rect(playerPosRect,Color(Color.PURPLE,0.5))

func _ready() -> void:
	queue_redraw()




