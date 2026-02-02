class_name BaseGrid 

var mapSize: Vector2
var mapGrid: Array[Array] = []

#mapSize
func setMapSize(size: Vector2) -> void:
	mapSize = size
	
func getMapSize() -> Vector2:
	return mapSize

func getMapGrid() -> Array[Array]:
	return mapGrid

#board
func createBoard():
 
	for pointX in range(mapSize.x ):
		var arrayY: Array[GridTile]
		for pointY in range(mapSize.y ):
			arrayY.append(GridTile.new(Vector2(pointX,pointY)))
				
		mapGrid.append(arrayY)



#gridMap
func setPosition_occupied(new_position:Vector2,old_position : Vector2 = Vector2.INF) -> void:
	if new_position.x < mapSize.x && new_position.y < mapSize.y:
		mapGrid[new_position.x][new_position.y].setOccupied(true)
		
		if old_position != Vector2.INF:
			mapGrid[old_position.x][old_position.y].setOccupied(false)
		
func resetPosition_occupied(position:Vector2) -> void:
	if position.x < mapSize.x && position.y < mapSize.y:
		mapGrid[position.x][position.y].setOccupied(false)
	
func isOccupiedPosition(position: Vector2) -> bool:
	print(position)

	return mapGrid[position.x][position.y].isOccupied()
