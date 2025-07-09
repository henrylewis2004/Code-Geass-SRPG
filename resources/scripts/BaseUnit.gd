class_name BaseUnit extends Path3D

signal movementFinished
signal attackFinished

@export_enum("player","enemy","ally") var team: int
@export var char_name: String
@export var charImage: Texture
@export var apCharge: int
@export var energyCharge: int

const SPEED: int = 2

@onready var bodyParts: Array[Node] = $bodyparts.get_children() #as Array[BodyPart]
@onready var weapons: Array[Node] = $weapons.get_children()
@onready var pathFollow : PathFollow3D = $PathFollow3D
@onready var itemsList: Node = $inventory/items
@onready var abilitiesList: Array[Node] = $inventory/abilities.get_children()

const BODYPARTS := preload("res://resources/scripts/enumClasses/ENUMbodyparts.gd").BODYPARTS

var equippedWeapon: int = -1
var ap: int
var energy: int

#stats
@export var maxAp: int
@export var agilityStat: int
@export var maxEnergy: int


@export var turnTimer: int = 0
@onready var predTurnTimer: int = turnTimer

#getters
func getGridPos() -> Vector2:
	return Vector2(position.x,position.z).floor()

func getPathPosition() -> Vector3:
	return (position + pathFollow.position + Vector3(0.5,0,0.5))

func getAp() -> int:
	return ap

func getMaxAp() -> int:
	return  maxAp

func getBodyparts() -> Array[Node]:
	return bodyParts

func getAliveBodyparts() -> Array[Node]:
	var partArr: Array[Node] = []
	for part in getBodyparts():
		if !part.isDestroyed():
			partArr.append(part)
			
	return partArr



func getName() -> String:
	return char_name

func getMoveRange() -> int:
	return bodyParts[BODYPARTS.LEGS].getMoveRange()

func getEnergy() -> int:
	return energy

func getMaxEnergy() -> int:
	return maxEnergy

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

#item abilities
func getItems() -> Array[Node]:
	return itemsList.get_children() 

func getAbilities() -> Array[Node]:
	return abilitiesList

#collisions
func getCollisionMask() -> int:
	return $PathFollow3D/unitCollider.collision_mask

func getCollider() -> Area3D:
	return $PathFollow3D/unitCollider


#weapons

func getEquippedWeapon() -> Weapon:
	if equippedWeapon < 0 || weapons[equippedWeapon].getEquipPart().isDestroyed(): return null

	return weapons[equippedWeapon]

func getEquippedWeaponIndex() -> int:
	return equippedWeapon

func getWeapons() -> Array[Node]:
	return weapons

func setEquippedWeapon(weapon: int) -> void:
	if weapon > 0 && weapon < weapons.size():
		equippedWeapon = weapon
		return
	
	equippedWeapon = -1

func weaponSelection(select: int) -> void:

	if equippedWeapon + select > weapons.size() - 1:
		equippedWeapon = 0

	elif equippedWeapon + select < 0:
		equippedWeapon = weapons.size() - 1
	
	else:
		equippedWeapon += select

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
	

#setters
func setMoveRange(moveRng: int) -> void:
	bodyParts[BODYPARTS.LEGS].setMoveRange(moveRng)

func setAp(newAp: int) -> void:
	ap = newAp

func resetAp() -> void:
	ap = maxAp
	
func resetEnergy() -> void:
	energy = maxEnergy
	
func incAp(val: int) -> void:
	ap += val
	if ap < 0: 
		ap = 0
	if ap > maxAp:
		resetAp()


func setBody(newBodyParts: Array[Node]) -> void:
	bodyParts = newBodyParts

func setName(newName: String) -> void:
	char_name = newName

func setGridPos(gridPos: Vector2) -> void:
	position = Vector3(gridPos.x,position.y,gridPos.y).floor()
	
func setTeam(newTeam: int) -> void:
	team = newTeam
	
	getCollider().set_collision_layer_value(11 + int(team == 1),true)
	getCollider().set_collision_layer_value(11 + int(team != 1),false)
	
#methods

#movement
func followPath(path: PackedVector2Array) -> void:
	for point in path:
		curve.add_point(Vector3(point.x,position.y,point.y) - position)
	set_process(true)
	
func moveTo(originPosIndex: int,targetPosIndex: int, astarMap: AStar2D) -> void:
	var path := astarMap.get_point_path(originPosIndex, targetPosIndex)
	followPath(path)

	
func hasLOS(enemyUnit: BaseUnit) -> bool:
	var collisionLayer: int = 1024 + 1024 * int(enemyUnit.getTeam() == 1)

	var raycast := PhysicsRayQueryParameters3D.create(Vector3(getGridPos().x,0,getGridPos().y) + Vector3(0.5,0,0.5), Vector3(enemyUnit.getGridPos().x,0,enemyUnit.getGridPos().y) + Vector3(0.5,0.5,0.5))
	raycast.collide_with_areas = true
	raycast.collision_mask = collisionLayer
	
	var result = get_world_3d().direct_space_state.intersect_ray(raycast)
	
	return (result && result.collider.get_parent().get_parent() == enemyUnit)



#battle
func validTarget(target: BaseUnit) -> bool:
	if ap < getEquippedWeapon().getApCost(): #not enough ap
		return false
	
	if target.getTeam() == team || (team == 0 && target.getTeam() == 2): #same team
		return false

	if abs(abs(getGridPos().x + getGridPos().y) - abs(target.getGridPos().x + target.getGridPos().y)) > getEquippedWeapon().getRange(): #out of range
		return false
	
	return true
	

func attack(unit: BaseUnit) -> void:
	var weapon : Weapon = getEquippedWeapon()
	var accuracy = weapon.getAccuracy()
	print(weapon)
	
	var wpnTimer: Timer = Timer.new() #maybe change to animation instead
	add_child(wpnTimer)
	wpnTimer.one_shot = true
	
	#add movement - turn unit around etc

	#accuracy
	if weapon.isTwoHanded():
		accuracy = accuracy / 2
		

	if unit.getBodyparts()[BODYPARTS.BODY].getHp() >= 0:
		ap -= weapon.apCost

		for round in range(weapon.getRounds()):
			#add dodge chance
			var hitRoll: int = randi() % 101
			if hitRoll <= accuracy:
				if hitRoll <= 10:
					#crit chance
					pass

				#hit
				var bodyPartHit: int = randi() % 4
				while unit.getBodyparts()[bodyPartHit].isDestroyed():
					bodyPartHit = randi() % 4			
				unit.getBodyparts()[bodyPartHit].hit(weapon.getDmg())
					
			else:
				#add miss gfx
				print("misss")
			wpnTimer.start(weapon.getWeaponFireRate())
			await wpnTimer.timeout
		
		for bodyPart in unit.getBodyparts():
			if bodyPart.getHp() <= 0:
				bodyPart.setDestroyed(true)
			

	remove_child(wpnTimer)
	wpnTimer.queue_free()
	attackFinished.emit()


#engine utility
func _ready():
	resetAp()
	setTeam(getTeam()) #sets collider for collisions
	
	if weapons.size() > 0:
		equippedWeapon = 0
	
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
