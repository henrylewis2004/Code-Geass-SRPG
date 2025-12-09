class_name chess_pawn extends chess_basePiece

func getMovePattern() -> Array[Vector2]:
	return [Vector2(0,-1 if getColour() == 0 else 1)]

func getAttackPattern() -> Array[Vector2]:
	return [Vector2(1,1),Vector2(-1,1)]

##
func _ready():
	setType(preload("res://chess/resources/enumClasses/ENUMchess.gd").CHESS_PIECES.PAWN,"pawn") #might need changing to make each object instance preload
	canPromote = true
	canMoveBack = false
	canMoveToEdge = false

	super()
	
