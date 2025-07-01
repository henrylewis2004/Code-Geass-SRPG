class_name BaseUnit extends Path3D

signal movementFinished

@export var team: int #0==player, 1==enemy, 2==ally
@export var char_name: String
@export var charImage: Texture
@export var apCharge: int

const SPEED: int = 2

@onready var bodyParts: Array[Node] = $bodyparts.get_children() #as Array[BodyPart]
@onready var weapons: Array[Node] = $weapons.get_children()
@onready var pathFollow : PathFollow3D = $PathFollow3D

var enumBodyParts := load("res://resources/scripts/enumClasses/ENUMbodyparts.gd")
var BODYPARTS = enumBodyParts.BODYPARTS

var equipedWeapon: Weapon = null
var ap: int

#stats
@export var maxAp: int
@export var agilityStat: int

@export var turnTimer: int = 0
@onready var predTurnTimer: int = turnTimer

#getters
func getGridPos() -> Vector2:
	return Vector2(position.x,position.z).floor()

func getAp() -> int:
	return ap

func getMaxAp() -> int:
	return  maxAp

func getBodyparts() -> Array[Node]:
	return bodyParts

func getName() -> String:
	return char_name

func getMoveRange() -> int:
	return bodyParts[BODYPARTS.LEGS].getMoveRange()

func getHP() -> Array[float]:
	var hpArray: Array[float]
	for bodypart in bodyParts:
		hpArray.append(bodypart.getHpRatio())
		
	return hpArray
		
func getCharImage() -> Texture:
	return charImage

func getTeam() -> int:
	return team

func getStat(stat:String) -> int:
	match(stat):
		"agility":
			return agilityStat
	return -1


#turn timer
func getTurnTimer() -> int:

	return turnTimer

func setTurnTimer(timer: int) -> void:
	turnTimer = timer
	
func incTurnTimer() -> void:
	turnTimer += agilityStat

func getPredTurnTimer() -> int:
	return predTurnTimer

func setPredTurnTimer(timer: int) -> void:
	predTurnTimer = timer
	
func resetPredTurnTimer() -> void:
	predTurnTimer = turnTimer
	
func getEquipedWeapon() -> Weapon:
	return equipedWeapon

#setters
func setMoveRange(moveRng: int) -> void:
	bodyParts[BODYPARTS.LEGS].setMoveRange(moveRng)

func setAp(newAp: int) -> void:
	ap = newAp

func setBody(newBodyParts: Array[Node]) -> void:
	bodyParts = newBodyParts

func setName(newName: String) -> void:
	char_name = newName

func setGridPos(gridPos: Vector2) -> void:
	position = Vector3(gridPos.x,position.y,gridPos.y).floor()
	
func resetAp() -> void:
	ap = maxAp
	
func setTeam(newTeam: int) -> void:
	team = newTeam
	
func setEquipedWeapon(newWeapon: Weapon) -> void:
	equipedWeapon = newWeapon
#methods
func followPath(path: PackedVector2Array) -> void:
	for point in path:
		curve.add_point(Vector3(point.x,position.y,point.y) - position)
	set_process(true)
	
func moveTo(originPosIndex: int,targetPosIndex: int, astarMap: AStar2D) -> void:
	var path := astarMap.get_point_path(originPosIndex, targetPosIndex)
	followPath(path)

	
func hasLOS(enemyLoc: Vector2) -> bool:
	#need to implement - come to when doing battle


	return false


#engine utility
func _ready():
	ap = maxAp
	
	if weapons.size() > 0:
		equipedWeapon = weapons[0]
	
	setGridPos(Vector2(position.x,position.z).floor())
	set_process(false)
	if not Engine.is_editor_hint():
		curve = Curve3D.new()
	
	#turnTimer += randi() % agilityStat
	
	
func _process(delta):
	pathFollow.progress += SPEED * delta
	
	if pathFollow.progress_ratio >= 1:
		set_process(false)
		position = curve.get_point_position(curve.point_count - 1) + position
		pathFollow.progress = 0
		curve.clear_points()
		movementFinished.emit()
