class_name BattleGrid extends BaseGrid

const SELECTION_TILE_ID := preload("res://resources/scripts/enumClasses/ENUM_unitSelectionTiles.gd").SELECTION_TILES_ID

var astar: AStar2D

var disabledPoints: Array[Vector2] = []

func setWorldWalls(size: Vector2, walls: Array[Node]) -> void:
	walls[0].position = Vector3(0,0,size.y) #north
	walls[1].position = Vector3(size.x,0,0) #east
	walls[2].position = Vector3(0,0,0) #south
	walls[3].position = Vector3(0,0,0) #west
	
	mapSize = size


func getASindex(cell: Vector2) -> int:
	return cell.x + cell.y * mapSize.y

func getAstar() -> AStar2D:
	return astar

func createBoard() -> AStar2D:
	astar = AStar2D.new()
 
	for pointX in range(mapSize.x ):
		var arrayY: Array[GridTile]
		for pointY in range(mapSize.y ):
			astar.add_point(getASindex(Vector2(pointX,pointY)), Vector2(pointX,pointY))
			if pointX - 1 >= 0:
				astar.connect_points(getASindex(Vector2(pointX - 1,pointY)), getASindex(Vector2(pointX,pointY)),true)
			if pointY - 1 >= 0:
				astar.connect_points(getASindex(Vector2(pointX,pointY - 1)), getASindex(Vector2(pointX,pointY)),true)
				
			arrayY.append(GridTile.new(Vector2(pointX,pointY)))
				
		mapGrid.append(arrayY)


	return astar

func init(size: Vector2,walls: Array[Node]) -> void:
	setWorldWalls(size,walls)
	createBoard()

func updateBoardCollisions(collisions: Array[Vector2]) -> AStar2D:
	for point in disabledPoints:
		astar.add_point(getASindex(point), point)

		if point.x - 1 >= 0:
			astar.connect_points(getASindex(point), getASindex(Vector2(point.x - 1,point.y)),true)
			
		if point.x + 1 < mapSize.x:
			astar.connect_points(getASindex(point), getASindex(Vector2(point.x + 1,point.y)),true)
			
		if point.y - 1 >= 0:
			astar.connect_points(getASindex(point), getASindex(Vector2(point.x,point.y - 1)),true)
			
		if point.y + 1 < mapSize.y:
			astar.connect_points(getASindex(point), getASindex(Vector2(point.x,point.y + 1)),true)
			
		resetPosition_occupied(Vector2(point.x,point.y))
			
	
	for position in collisions:
		astar.remove_point(getASindex(position))
		setPosition_occupied(position)

	disabledPoints = collisions

	return astar

		

#methods
func absDist(pos1: Vector2, pos2: Vector2) -> int:
	return abs(pos1.x - pos2.x) + abs(pos1.y - pos2.y)

func dist(targetPos: Vector2, curPos: Vector2 ) -> int:
	return (getPath(curPos,targetPos).size() - 1)

func getPath(pos1: Vector2, pos2: Vector2) -> PackedVector2Array:
	return astar.get_point_path(getASindex(pos1),getASindex(pos2))

func validMove(loc: Vector2, unit: BaseUnit) -> bool:
	var dist: int = dist(loc,unit.getGridPos())
	return (dist <= unit.getMoveRange() && dist > 0)


func apMoveCost(originPos: Vector2, targetPos: Vector2) -> int:
	return dist(originPos,targetPos)

#unit tiles
func createUnitMoveTiles(tileGrid: GridMap, dist: int, originPos: Vector2) -> void:
	#might need changing for different ap costs depending on tile type
	const type: int = SELECTION_TILE_ID.BLUE
	
	tileGrid.set_cell_item(Vector3(originPos.x,0,originPos.y),type)
	
	for index_X in range(dist + 1):
		for index_y in range(dist + 1):
			if index_X + index_y > dist:
				break

			var pathDist = dist(originPos,originPos + Vector2(index_X,index_y)) 
			if pathDist <= dist && pathDist > 0:
				tileGrid.set_cell_item(Vector3(originPos.x,0,originPos.y) + Vector3(index_X,0,index_y), type)

			pathDist = dist(originPos,originPos - Vector2(index_X,index_y)) 
			if pathDist <= dist && pathDist > 0:
				tileGrid.set_cell_item(Vector3(originPos.x,0,originPos.y) - Vector3(index_X,0,index_y), type)

			if index_X != 0 && index_y != 0:
				pathDist = dist(originPos,originPos + Vector2(-index_X,index_y)) 
				if pathDist <= dist && pathDist > 0:
					tileGrid.set_cell_item(Vector3(originPos.x,0,originPos.y) + Vector3(-index_X,0,index_y), type)

				pathDist = dist(originPos,originPos + Vector2(index_X,-index_y)) 
				if pathDist <= dist && pathDist > 0:
					tileGrid.set_cell_item(Vector3(originPos.x,0,originPos.y) + Vector3(index_X,0,-index_y), type)


func createUnitAttackTiles(tileGrid: GridMap, range:int, originPos: Vector2) -> void:
	const type: int = SELECTION_TILE_ID.RED

	for index_X in range(range + 1):
		for index_y in range(range + 1):
			if index_X + index_y > range:
				break
			
			tileGrid.set_cell_item(Vector3(originPos.x,0,originPos.y) + Vector3(index_X,0,index_y), type)

			tileGrid.set_cell_item(Vector3(originPos.x,0,originPos.y) - Vector3(index_X,0,index_y), type)

			tileGrid.set_cell_item(Vector3(originPos.x,0,originPos.y) + Vector3(-index_X,0,index_y), type)

			tileGrid.set_cell_item(Vector3(originPos.x,0,originPos.y) + Vector3(index_X,0,-index_y), type)


func createItemPrevTiles(tileGrid: GridMap, range: int, originPos: Vector2, attack: bool) -> void:
	var type: int = SELECTION_TILE_ID.YELLOW 

	if attack:
		type = SELECTION_TILE_ID.RED 

	for index_X in range(range + 1):
		for index_y in range(range + 1):
			if index_X + index_y > range:
				break
			
			tileGrid.set_cell_item(Vector3(originPos.x,0,originPos.y) + Vector3(index_X,0,index_y), type)

			tileGrid.set_cell_item(Vector3(originPos.x,0,originPos.y) - Vector3(index_X,0,index_y), type)

			tileGrid.set_cell_item(Vector3(originPos.x,0,originPos.y) + Vector3(-index_X,0,index_y), type)

			tileGrid.set_cell_item(Vector3(originPos.x,0,originPos.y) + Vector3(index_X,0,-index_y), type)


func createUnitTile(tileGrid: GridMap, position: Vector3, type:int) -> void:
	tileGrid.set_cell_item(position,type)
	
func createUnitTiles_FromArray(tileGrid: GridMap, unitArray: Array[Node]) -> void:
	for unit in unitArray:
		tileGrid.set_cell_item(unit.position,unit.getTeam())


func clearUnitSelectionTiles(tileGrid: GridMap) -> void:
	tileGrid.clear()

func getGridPos_fromV3(pos: Vector3) -> Vector2:
	return Vector2(pos.x,pos.z)

func getGridPos_fromV3_Array(posArray: Array[Vector3i]) -> Array[Vector2]:
	var res: Array[Vector2] = []
	for position in posArray:
		res.append(getGridPos_fromV3(position))
	return res

	
