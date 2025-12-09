class_name chess_bishop extends chess_basePiece

func getMovePattern() -> Array[Vector2]:
	return [Vector2(1,1),Vector2(-1,1),Vector2(1,-1),Vector2(-1,-1)]

##
func _ready():
	setType(preload("res://chess/resources/enumClasses/ENUMchess.gd").CHESS_PIECES.BISHOP,"bishop") #might need changing to make each object instance preload
	super()
