class_name chess_king extends chess_basePiece

func getMovePattern() -> Array[Vector2]:
	return [Vector2(1,0),Vector2(0,1),Vector2(1,1),Vector2(-1,0),Vector2(0,-1),Vector2(-1,-1), Vector2(1,-1), Vector2(-1,1)]

##
func _ready():
	setType(preload("res://chess/resources/enumClasses/ENUMchess.gd").CHESS_PIECES.KING,"king") #might need changing to make each object instance preload
	canMoveToEdge = false

	super()
