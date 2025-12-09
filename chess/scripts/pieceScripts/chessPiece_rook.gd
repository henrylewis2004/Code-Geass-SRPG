class_name chess_rook extends chess_basePiece

func getMovePattern() -> Array[Vector2]:
	return [Vector2(1,0),Vector2(0,1),Vector2(-1,0),Vector2(0,-1)]

##
func _ready():
	setType(preload("res://chess/resources/enumClasses/ENUMchess.gd").CHESS_PIECES.ROOK,"rook") #might need changing to make each object instance preload
	super()
