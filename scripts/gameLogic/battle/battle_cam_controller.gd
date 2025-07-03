class_name BattleCamController extends CharacterBody3D

signal cinematicMoveFinished 

@onready var _CameraPivot := $camPivot as Node3D
@onready var gridTile := $CollisionShape3D as CollisionShape3D

var moveDir: Vector2 = Vector2()
const moveSpeed: int = 5
const camSensitivity: float = 0.07

var canMove: bool = true
var canRot: bool = true

var movingToLoc: Vector3 = Vector3.INF
var unitFollow: BaseUnit = null

#cam movement functions
func movement() -> void:
	if canMove:
		moveDir = Input.get_vector("cam_left", "cam_right", "cam_forward","cam_back")
		velocity = Vector3(moveDir.x, 0,moveDir.y).rotated(Vector3.UP, _CameraPivot.rotation.y) * moveSpeed #might need to change to add y vector, move up or down

	elif movingToLoc != Vector3.INF:
		if (position * 10).round()/10 == movingToLoc.floor() + Vector3(0.5,0,0.5):
			movingToLoc = Vector3.INF
			velocity = velocity * 0
			emit_signal('cinematicMoveFinished')
	else:
		velocity = velocity * 0
		
	move_and_slide()
	
	if unitFollow != null:
		position = unitFollow.getPathPosition()

	if canRot:
		camRotation()
	
func camRotation() -> void:
	_CameraPivot.rotate_y(Input.get_axis("cam_rot_left", "cam_rot_right") * camSensitivity )
	
	
func followUnit(unit: BaseUnit) -> void:
	unitFollow = unit
	
func clearUnitFollow() -> void:
	unitFollow = null



	
#grid functions
func moveToGridPos(loc: Vector3, speed: int) -> void:
	movingToLoc = loc + Vector3(0.5,0,0.5)
	velocity = (movingToLoc - position) * speed
	canMove = false
	
func snapToGridPos(pos: Vector2) -> void:
	position = Vector3(pos.floor().x,position.y,pos.floor().y) + Vector3(0.5,0,0.5)
	
func getGridPos() -> Vector2:
	return Vector2(position.x,position.z).floor()




#movement locks
func lockMovement(lock: bool):
	canMove = !lock
	
func lockRot(lock: bool):
	canRot = !lock
	
func lockInput (lock: bool):
	lockMovement(lock)
	lockRot(lock)
	
func input(lockMovement: bool, lockRotation: bool) -> void:
	lockMovement(lockMovement)
	lockRot(lockRotation)
	
func islocked() -> bool:
	return (!canMove || !canRot)

	
#engine interaction
func _physics_process(delta):
	movement()
	
