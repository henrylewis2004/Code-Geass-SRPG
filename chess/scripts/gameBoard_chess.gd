class_name ChessGameBoard extends BaseGrid

const cellSize: Vector2 = Vector2(32,32)
const startLoc: Vector2 = Vector2(112,4)


func getCellSize() -> Vector2:
	return cellSize

func getStartLoc() -> Vector2:
	return startLoc

#position
func alignToGrid(pieces: Array[Node]) -> void:
	for piece in pieces:
		setGridPos(piece,((piece.position - startLoc) / cellSize.x).floor())
		setPieceSpriteLoc(piece)


func setGridPos(piece: chess_basePiece,pos: Vector2) -> void:
	mapGrid[piece.getGridPos().x][piece.getGridPos().y] = null

	piece.position = startLoc + pos.floor() * cellSize
	piece.gridPos = pos

	mapGrid[piece.getGridPos().x][piece.getGridPos().y] = piece

func setPieceSpriteLoc(piece: chess_basePiece) -> void:
	piece.getSprite().position = cellSize / 2

func getGridPos(piece: chess_basePiece) -> Vector2:
	return piece.getGridPos()

##board
func outOfBounds(pos1: Vector2, pos2: Vector2) -> bool:
	if pos1.x + pos2.x < 0 || pos1.y + pos2.y < 0 : return true
	if pos1.x + pos2.x >= 8 || pos1.y + pos2.y >= 8 : return true

	return false

func updateMapGrid(pieces: Array[Node]) -> void:
	for piece in pieces:
		mapGrid[piece.getGridPos().x][piece.getGridPos().y] = piece

	for point in mapGrid:
		print(point)

func createBoard() -> void:
	for pointX in range(mapSize.x ):
		var arrayY: Array[Node]
		for pointY in range(mapSize.y ):
			arrayY.append(null)
				
		mapGrid.append(arrayY)


#get unit
func getUnitAt(pos: Vector2) -> chess_basePiece:
	if pos.x >= mapSize.x || pos.x < 0 || pos.y >= mapSize.y || pos.y < 0: return null
	return mapGrid[pos.x][pos.y]

#get unitMovementTiles
func getMoveTiles(piece: chess_basePiece) -> Array[Vector2]:
	var arr: Array[Vector2] = []
	if piece.moveToEdge():
		arr = patRec(true,piece.getGridPos(),piece.getMovePattern())


	else:
		for pat in piece.getMovePattern():
			if !outOfBounds(piece.getGridPos(),pat) && getUnitAt(piece.getGridPos() + pat) == null:
				arr.append(piece.getGridPos() + pat)


	return arr

func getAttackTiles(piece:chess_basePiece) -> Array[Vector2]:
	var arr: Array[Vector2] = []

	if piece.moveToEdge():
		arr = patRec(false,piece.getGridPos(),piece.getAttackPattern(),piece.getColour())


	else:
		for pat in piece.getAttackPattern():
			if !outOfBounds(piece.getGridPos(),pat) && getUnitAt(piece.getGridPos() + pat) != null && getUnitAt(piece.getGridPos()+pat).getColour() != piece.getColour():
				arr.append(piece.getGridPos() + pat)


	return arr

	
func patRec(move: bool, piecePos: Vector2,patterns: Array[Vector2], pieceCol:int = -1,cnt:int = 1,tiles: Array[Vector2] = []) -> Array[Vector2]:
	if patterns.size() == 0:
		return tiles

	var removeIndex: Array[int] = []

	for patIndex in range(patterns.size()):
		var pat = patterns[patIndex] * cnt

		if getUnitAt(piecePos + pat) != null || outOfBounds(piecePos,pat):
			removeIndex.append(patIndex)
			if (move == false && getUnitAt(piecePos + pat) != null && getUnitAt(piecePos + pat).getColour() != pieceCol):

				tiles.append(piecePos + pat)

		elif move == true:
			tiles.append(piecePos + pat)

	for index in range(removeIndex.size() - 1, -1, -1):
		patterns.remove_at(removeIndex[index])

	cnt += 1
	return patRec(move,piecePos,patterns,pieceCol,cnt,tiles)


#engine
func _init(pieces: Array[Node]) -> void:
	setMapSize(Vector2(8,8))
	createBoard()
	alignToGrid(pieces)
