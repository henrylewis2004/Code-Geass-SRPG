class_name ChessGameBoard extends BaseGrid

func _ready():
	setMapSize(Vector2(8,8))
	createBoard()

