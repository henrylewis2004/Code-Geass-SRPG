class_name Grid 

var mapSize: Vector2
var astar: AStar2D

func setMapSize(size: Vector2) -> void:
	mapSize = size

func setWorldWalls(size: Vector2, walls: Array[Node]) -> void:
	walls[0].position = Vector3(0,0,size.y) #north
	walls[1].position = Vector3(size.x,0,0) #east
	walls[2].position = Vector3(0,0,0) #south
	walls[3].position = Vector3(0,0,0) #west
	
	mapSize = size


#A*
func getASindex(cell: Vector2) -> int:
	return int(cell.x + mapSize.x * cell.y)

func createBoard(collisions: Array[Vector2]) -> void:
	astar = AStar2D.new()
 
	for pointX in range(mapSize.x):
		for pointY in range(mapSize.y):
			astar.add_point(getASindex(Vector2(pointX,pointY)), Vector2(pointX,pointY))
			if pointX - 1 >= 0:
				astar.connect_points(getASindex(Vector2(pointX - 1,pointY)), getASindex(Vector2(pointX,pointY)),true)
			if pointY - 1 >= 0:
				astar.connect_points(getASindex(Vector2(pointX,pointY - 1)), getASindex(Vector2(pointX,pointY)),true)

	#for point in collisions:
	#	astar.remove_point(getASindex(Vector2(point.x,point.y)))
		

#methods

func absDist(pos1: Vector2, pos2: Vector2) -> int:
	return abs(pos1.x - pos2.x) + abs(pos1.y - pos2.y)

func dist(targetPos: Vector2, curPos: Vector2 ) -> int:
	return astar.get_Point_Path(curPos,targetPos).size() - 1

func getPath(pos1: Vector2, pos2: Vector2) -> PackedVector2Array:

	return astar.get_point_path(getASindex(pos1),getASindex(pos2))
