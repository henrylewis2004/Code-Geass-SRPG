class_name chess_knight extends chess_basePiece

func getMovePattern() -> Array[Vector2]:
	return [Vector2(1,2),Vector2(-1,2),Vector2(-2,1),Vector2(-2,-1),Vector2(2,-1),Vector2(2,1),Vector2(1,-2),Vector2(-1,-2)]

##
func _ready():
	setType(preload("res://chess/resources/enumClasses/ENUMchess.gd").CHESS_PIECES.KNIGHT,"knight") #might need changing to make each object instance preload
	jumpPieces = true 
	canMoveToEdge = false

	super()
