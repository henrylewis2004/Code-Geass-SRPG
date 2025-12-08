class_name chess_pawn extends chess_basePiece



func _ready():
	setType(preload("res://chess/resources/enumClasses/ENUMpieces.gd").CHESS_PIECES.PAWN) #might need changing to make each object instance preload
	canPromote = true
