class_name BaseUnit extends Path3D

signal movementFinished
signal attackFinished
signal destroy_unit(unit: BaseUnit)

@export_enum("player","enemy","ally") var team: int
@export var char_name: String
@export var charImage: Texture


#status info
@export var full_name: String
@export var status_charImg: Texture
@export var factionName: String

const SPEED: int = 2

@onready var bodyParts: Array[Node] = $bodyparts.get_children() #as Array[BodyPart]
@onready var weapons: Array[Node] = $weapons.get_children()
@onready var pathFollow : PathFollow3D = $PathFollow3D
@onready var itemsList: Node = $inventory/items
@onready var abilitiesList: Array[Node] = $inventory/abilities.get_children()

const BODYPARTS := preload("res://resources/scripts/enumClasses/ENUMbodyparts.gd").BODYPARTS
const STATS := preload("res://resources/scripts/enumClasses/ENUMstats.gd").UNIT_STATS
const ATTACK_STATS  := preload("res://resources/scripts/enumClasses/ENUMtypes.gd").ATTACK_STAT

var equippedWeapon: int = -1
var ap: int
var energy: int
var typeMan: typeManager = typeManager.new()

const maxDmgMod: Dictionary = {"min": 0.1,"max": 4.0}

#stats
@export var agilityStat: int
@export var defenceStat: int
@export var evasionStat: int
@export var meleeStat: int
@export var rangedStat: int
@export var maxAp: int
@export var apCharge: int
@export var maxEnergy: int
@export var energyCharge: int
@export var luckStat: int
@export var iniativeStat: int
@onready var stats: Stats = Stats.new(agilityStat, defenceStat,evasionStat,meleeStat,rangedStat,maxAp,apCharge,maxEnergy,energyCharge,luckStat,iniativeStat)

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
	return  stats.getStat(STATS.AP)

func getBodyparts() -> Array[Node]:
	return bodyParts

func getAliveBodyparts() -> Array[Node]:
	var partArr: Array[Node] = []
	for part in getBodyparts():
		if !part.isDestroyed():
			partArr.append(part)
			
	return partArr


func isDestroyed() -> bool:
	return getBodyparts()[BODYPARTS.BODY].isDestroyed()

func getName() -> String:
	return char_name

func getMoveRange() -> int:
	return min(getAp(),bodyParts[BODYPARTS.LEGS].getMoveRange())

func getAbsMoveRange() -> int:
	return bodyParts[BODYPARTS.LEGS].getAbsMoveRange()

func getEnergy() -> int:
	return energy

func getMaxEnergy() -> int:
	return maxEnergy

func getAbsHP() -> Array[int]:
	var hpArray: Array[int] = []
	for bodypart in bodyParts:
		hpArray.append(bodypart.getHp())
	return hpArray

func getHP() -> Array[float]:
	var hpArray: Array[float]
	for bodypart in bodyParts:
		hpArray.append(bodypart.getHpRatio())
		
	return hpArray
		
func getCharImage() -> Texture:
	return charImage

func getTeam() -> int:
	return team

func getStats() -> Stats:
	return stats


func getStat(stat:int) -> int:
	return stats.getStat(stat)

#status getters
func getFullName() -> String:
	return full_name
func getStatusImg() -> Texture:
	return status_charImg
func getFactionName() -> String:
	return factionName

#item abilities
func getItems() -> Array[Node]:
	return itemsList.get_children() 

func getAbilities() -> Array[Node]:
	return abilitiesList

func removeItem(item: BattleItem) -> void:
	for i in getItems():
		if i == item:
			itemsList.remove_child(i)
	item.queue_free()

func removeAbility(item: Ability) -> void:
	for i in getItems():
		if i == item:
			itemsList.remove_child(i)
	item.queue_free()


#collisions
func getCollisionMask() -> int:
	return $PathFollow3D/unitCollider.collision_mask

func getCollider() -> Area3D:
	return $PathFollow3D/unitCollider

func getBodyPartDefenceType(bodyPart: int) -> int:
	return bodyParts[bodyPart].getDefenceType()

func missingArm() -> bool:
	return bodyParts[BODYPARTS.R_ARM].isDestroyed() || bodyParts[BODYPARTS.L_ARM].isDestroyed()

#weapons

func getEquippedWeapon() -> Weapon:
	if equippedWeapon < 0 || weapons[equippedWeapon].getEquipPart().isDestroyed(): return null

	return weapons[equippedWeapon]

func getEquippedWeaponIndex() -> int:
	return equippedWeapon

func getEquippedWeaponType() -> int:
	return getEquippedWeapon().getAttackType() #might return bug if equipped weapon returns null

func getWeapons() -> Array[Node]:
	return weapons

func setEquippedWeapon(weapon: int) -> void:
	if weapon > 0 && weapon < weapons.size():
		equippedWeapon = weapon
		return
	
	equippedWeapon = -1
	
func equipAWeapon() -> void:
	for weapon in range(0,weapons.size() - 1):
		if !weapons[weapon].getEquipPart().isDestroyed():
			setEquippedWeapon(weapon + 1)
			return
	
func setEquippedWeapon_fromWeapon(weapon: Weapon) -> void:
	if weapon != null:
		for weaponIndex in range(getWeapons().size()):
			if weapon == weapons[weaponIndex]:
				equippedWeapon = weaponIndex
				return

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
	turnTimer += stats.getStat(STATS.AGILITY)

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
	ap = stats.getStat(STATS.AP)
	
func unitApCharge() -> void:
	incAp(apCharge)
	
func resetEnergy() -> void:
	energy = stats.getStat(STATS.ENERGY)

func unitEpCharge() -> void:
	incEnergy(energyCharge)

func incEnergy(val: int = getStat(STATS.ENERGY_CHARGE)) -> void:
	energy += val
	if energy < 0:
		energy = 0
	if energy > stats.getStat(STATS.ENERGY):
		resetEnergy()
	
func incAp(val: int = getStat(STATS.AP_CHARGE)) -> void:
	ap += val
	if ap < 0: 
		ap = 0
	if ap > stats.getStat(STATS.AP):
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
	
func moveCost(originPosIndex:int,targetPosIndex:int,astarMap:AStar2D) -> int:
	return astarMap.get_point_path(originPosIndex,targetPosIndex).size() - 1

	
func hasLOS(enemyUnit: BaseUnit,gridPosition:Vector3 = self.position.floor() ) -> bool:
	var collisionLayer: int = 1024 + 1024 * int(enemyUnit.getTeam() == 1)

	var raycast := PhysicsRayQueryParameters3D.create(gridPosition + Vector3(0.5,0,0.5), enemyUnit.position.floor() + Vector3(0.5,0.5,0.5))
	raycast.collide_with_areas = true
	raycast.collision_mask = collisionLayer
	
	var result = get_world_3d().direct_space_state.intersect_ray(raycast)
	
	return (result && result.collider.get_parent().get_parent() == enemyUnit)



#battle
func getWeaponStatHitAffect(weaponStat: int) -> int:
	match(weaponStat):
		ATTACK_STATS.RANGED:
			return getStat(STATS.RANGED)
		
		ATTACK_STATS.MELEE:
			return getStat(STATS.MELEE)

	print("error in weaponStatHitAffect, likely wrong weaponStat assigned to equipped weapon")
	return 0


func getAttackDmgStOffset(attackStat: int, defenceStat: int) -> float:
	return 1 + (attackStat - defenceStat)/100

func getAttackHitMissOffset(attackStat: int, evadeStat: int) -> int:
	return 100 + attackStat - evadeStat

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
	
	var wpnTimer: Timer = Timer.new() #maybe change to animation instead
	add_child(wpnTimer)
	wpnTimer.one_shot = true
	
	#add movement - turn unit around etc

	#accuracy
	if weapon.isTwoHanded() && self.missingArm():
		accuracy = accuracy / 2
		

	if unit.getBodyparts()[BODYPARTS.BODY].getHp() >= 0:
		ap -= weapon.apCost

		var crit: bool =  randi() % 101 < getStat(STATS.LUCK) / 4 + 2.5
		var evade: bool = false
		if !crit:
			evade = randi() % 101 < getStat(STATS.EVASION) / 10

		if !evade:
			for round in range(weapon.getRounds()):
				#add dodge chance
				var hitRoll: int = randi() % 101 

				if hitRoll <= accuracy + getAttackHitMissOffset(self.getWeaponStatHitAffect(getEquippedWeapon().getAttackStat()),unit.getStat(STATS.EVASION)) || crit:
					#which bodypart is hit
					var bodyPartHit: int = randi() % 4
					while unit.getBodyparts()[bodyPartHit].isDestroyed():
						bodyPartHit = randi() % 4			

					#base dmgmod
					var dmgMod: float = 1.0

					#weapon type mod
					dmgMod = dmgMod * (typeMan.getTypeAffectAttack(self.getEquippedWeapon().getAttackType(),unit.getBodyPartDefenceType(bodyPartHit)))

					#weapon stat mod (ranged / melee) - unit defenceBonus
					dmgMod = dmgMod * getAttackDmgStOffset(getWeaponStatHitAffect(getEquippedWeapon().getAttackStat()),unit.getStat(STATS.DEFENCE))

					
					#crit mod
					if crit:
						dmgMod = dmgMod * 1.5


					if dmgMod < maxDmgMod["min"]:
						dmgMod = maxDmgMod["min"]
					elif dmgMod > maxDmgMod["max"]:
						dmgMod = maxDmgMod["max"]

					#hit

					unit.getBodyparts()[bodyPartHit].hit(int(weapon.getDmg() * dmgMod))
						
				else:
					pass
					#add miss gfx
				wpnTimer.start(weapon.getWeaponFireRate())
				await wpnTimer.timeout
		
		for bodyPart in unit.getBodyparts():
			if bodyPart.getHp() <= 0:
				bodyPart.setDestroyed(true)
			

	remove_child(wpnTimer)
	wpnTimer.queue_free()
	attackFinished.emit()

##
func newTurn() -> void:
	incEnergy()
	incAp()
	stats.timeStatusAffect()




#engine utility
func _ready():
	resetAp()
	resetEnergy()
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
