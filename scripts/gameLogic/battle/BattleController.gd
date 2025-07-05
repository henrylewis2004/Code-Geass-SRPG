class_name BattleController extends Node

enum STATE{E_UNIT_ATTACK,NONE,A_UNIT_CAM_CINEMATIC,CAM_CINEMATIC,UNIT_MENU,CAM_MOVEMENT,A_UNIT,UNIT_MOVEMENT_SELECTION,ATTACK_MOVEMENT,E_UNIT,BATTLE,A_UNIT_MOVED,E_UNIT_SELECTED_ATTACK}
var curState: int = STATE.CAM_MOVEMENT #might need to change to none as default

enum TEAM {PLAYER,ENEMY,ALLY}
enum UNIT_SELECT_TILE{MOVE,ATTACK,INTERACT}
enum ACTION_BOX_ITEM{ATTACK,MOVE,STATUS,ITEM,END}

const BODYPARTS := preload("res://resources/scripts/enumClasses/ENUMbodyparts.gd").BODYPARTS

@onready var battleCam: BattleCamController = $BattleCam
@onready var playerUnits: Array[Node] = $battleUnits/playerUnits.get_children() 
@onready var enemyUnits: Array[Node] = $battleUnits/enemyUnits.get_children() 
@onready var allyUnits: Array[Node] = $battleUnits/allyUnits.get_children()


@onready var playerUnitGui: AllyUnitGui = $ui/AllyUnitGui 
@onready var enemyUnitGui: BattleUnitGui  = $ui/EnemyUnitGui
const confirmBox := preload("res://scenes/game logic/menus/Confirmation Window.tscn")

@onready var turnManager: TurnManager = $TurnManager
var aiManager : AiManager = AiManager.new()

var apCost: Vector2 = Vector2.INF #x = ap at start of turn, y = ap after move, then final ap taken in attack phase and turn ends

#grid
@export var mapSize: Vector2
var gridManager: Grid = Grid.new() 

@onready var collisionWalls := $Grid/worldWalls.get_children() 
var astarBoard: AStar2D 

@onready var unitSelectionTiles : GridMap = $Grid/unitSelection
#

var playerTurn: bool = true
var unitPos: Array[Vector2]

var unitTurn: BaseUnit = null
var selectedEnemyUnit: BaseUnit = null

var selectedAllyUnit: BaseUnit = null
var selectedAllyUnitIndex: int = 0
var unitOriginPos: Vector2 = Vector2.INF

var utilFun: Util = Util.new()

#methods
func updateUnitGridPos() -> void:
	unitPos = []

	for unit in playerUnits:
		unitPos.append(unit.getGridPos())

	for unit in enemyUnits:
		unitPos.append(unit.getGridPos())

	for unit in allyUnits:
		unitPos.append(unit.getGridPos())
		
	

		
#cam movement allowment
func canCamMove() -> bool:
	return (curState == STATE.CAM_MOVEMENT || curState == STATE.UNIT_MOVEMENT_SELECTION || curState == STATE.ATTACK_MOVEMENT)

func canCamRot() -> bool:
	return !(curState == STATE.NONE || curState == STATE.BATTLE)

#unit overlay
func unitOverlay() -> void:
	var camPos: Vector2 = battleCam.getGridPos()
	playerUnitGui.set_visible(false)
	enemyUnitGui.set_visible(false)
	
	for pos in range(unitPos.size()):
		if unitPos[pos] == camPos:
			if pos < playerUnits.size():
				selectUnitOverlay(playerUnits[pos], TEAM.PLAYER)
				break
				

			elif pos < playerUnits.size() + enemyUnits.size():
				selectUnitOverlay(enemyUnits[pos - playerUnits.size()], TEAM.ENEMY)
				break 
			
			else:
				selectUnitOverlay(allyUnits[pos - playerUnits.size() - enemyUnits.size()], TEAM.ALLY)
				break 
			

	if showPlayerUnit():
		selectUnitOverlay(unitTurn,unitTurn.getTeam())
		
	if curState == STATE.E_UNIT_SELECTED_ATTACK:
		var text = str(unitTurn.getEquippedWeapon().getAccuracy()) + "%"
		if unitTurn.getAp() < unitTurn.getEquippedWeapon().getApCost(): text = "NO AP"
		if !unitTurn.hasLOS(selectedEnemyUnit): text = "NO LOS"
		if gridManager.absDist(selectedEnemyUnit.getGridPos(),unitTurn.getGridPos()) > unitTurn.getEquippedWeapon().getRange(): text = "OUT OF\nRANGE"

		unitTurn.drawAccText(selectedEnemyUnit.position,text, Color.RED)

func selectUnitOverlay(unit: BaseUnit, team: int) -> void: #team : 0= enemy, 1= player, 2= ally
	if team == TEAM.PLAYER:
		playerUnitGui.set_visible(true)
		playerUnitGui.updateBase(unit.getName(),unit.getAp(),unit.getCharImage(),unit.getHP())
		
		if curState == STATE.ATTACK_MOVEMENT:
			playerUnitGui.setExpansionInfo(unit.getEquippedWeapon())
			playerUnitGui.expand()
	
	elif team == TEAM.ENEMY:
		enemyUnitGui.set_visible(true)
		enemyUnitGui.updateBase(unit.getName(),unit.getAp(),unit.getCharImage(),unit.getHP())

		if curState == STATE.E_UNIT || curState == STATE.E_UNIT_SELECTED_ATTACK || curState == STATE.ATTACK_MOVEMENT:
			enemyUnitGui.setExpansionInfo(unit.getEquippedWeapon())
			enemyUnitGui.expand()
	
	#add enemy + ally unit overlay

func showPlayerUnit() -> bool :
	return (curState ==  STATE.A_UNIT_CAM_CINEMATIC || curState == STATE.UNIT_MOVEMENT_SELECTION || curState == STATE.ATTACK_MOVEMENT || curState == STATE.E_UNIT_SELECTED_ATTACK || curState == STATE.E_UNIT_ATTACK)

func playerInput(unit: BaseUnit) -> void:
	playerUnitGui.showActionBox()
	
	battleCam.snapToGridPos(unit.getGridPos())
	
	
#unit selection
func unitInteraction() -> BaseUnit:
	var camPos: Vector2 = battleCam.getGridPos()
	
	#player units
	for unit in playerUnits:
		if unit.getGridPos() == camPos:
			return unit
		
	#enemy units
	for unit in enemyUnits:
		if unit.getGridPos() == camPos:
			return unit 

	#ally units
	for unit in allyUnits:
		if unit.getGridPos() == camPos:
			return unit 

	return null

func selectNextUnit(index: int) -> void: #might need changing - add state options  
	
	#change to select enemy units
	var select: int = index + selectedAllyUnitIndex
	if index + selectedAllyUnitIndex >= playerUnits.size():
		select = 0
	elif index + selectedAllyUnitIndex < 0:
		select = playerUnits.size() - 1
		
	selectAllyUnit(select)
	
func selectUnit(unit: BaseUnit) -> void:#needs modification
	unitTurn = unit
	battleCam.snapToGridPos(unit.getGridPos())
	
	apCost.x = unitTurn.getAp()
	
	
func unitTurnMoved() -> void:
	if unitTurn.getGridPos() != unitOriginPos && unitOriginPos != Vector2.INF:
		curState = STATE.A_UNIT_MOVED
		playerUnitGui.showItem_actionBox(ACTION_BOX_ITEM.MOVE,false)
		return
	curState = STATE.A_UNIT
	

	
func selectAllyUnit(index: int) -> void: 
	selectedAllyUnit = playerUnits[index]
	selectedAllyUnitIndex = index
	battleCam.snapToGridPos(selectedAllyUnit.getGridPos())
	
	
#handles player input
func input() -> void:
	if Input.is_action_just_pressed("accept"):
		match (curState):
			STATE.CAM_MOVEMENT:
				var unit: BaseUnit = unitInteraction()
				if unit != null:
					match(unit.getTeam()):
						TEAM.PLAYER: #player unit
							playerUnitGui.showActionBox()
							battleCam.snapToGridPos(unitTurn.getGridPos())

							curState = STATE.A_UNIT

						
						TEAM.ENEMY: #add enemy units
							print("enemy")

						
						TEAM.ALLY: #add ally units
							print("ally")

			STATE.UNIT_MOVEMENT_SELECTION:
				var unit: BaseUnit = unitInteraction()
				if unit != null: # need to do
					#add in unit selection 
					match(unit.getTeam()): 
						TEAM.PLAYER:
							pass
						#add enemy units
						TEAM.ENEMY:
							pass
						TEAM.ALLY:
							pass
					
				else: #no unit selected
					var targetLoc: Vector2 = battleCam.getGridPos() #need to add valid location check
					if gridManager.validMove(targetLoc,unitTurn):
						unitTurn.incAp(-gridManager.apMoveCost(unitTurn.getGridPos(),targetLoc))
						apCost.y = unitTurn.getAp()

						gridManager.clearUnitSelectionTiles(unitSelectionTiles)
						unitTurn.moveTo(gridManager.getASindex(unitTurn.getGridPos()), gridManager.getASindex(targetLoc),astarBoard)
						
						battleCam.followUnit(unitTurn)
						curState = STATE.A_UNIT_CAM_CINEMATIC
						
						await unitTurn.movementFinished

						updateUnitGridPos()
						playerUnitGui.showItem_actionBox(ACTION_BOX_ITEM.MOVE,false)
						playerInput(unitTurn)

						battleCam.clearUnitFollow()
						curState = STATE.A_UNIT_MOVED
					
			STATE.ATTACK_MOVEMENT:
				#add attack orders
				var unit: BaseUnit = unitInteraction()
				if unit != null:
					#add in unit selection 
					match(unit.getTeam()):
						TEAM.PLAYER: #need to add
							if (unitTurn != unit):
								pass

							else: #unit turn selected
								unitTurnMoved()
								playerInput(unitTurn)
						TEAM.ALLY:
							pass

						TEAM.ENEMY:
							#valid target - loc and range
							if unitTurn.validTarget(unit) && unitTurn.hasLOS(unit):
								curState = STATE.E_UNIT_SELECTED_ATTACK
								battleCam.snapToGridPos(unit.getGridPos())
								
								selectedEnemyUnit = unit
								
								#add line between uints - maybe add to unit code 
								unitTurn.drawLos(selectedEnemyUnit, Color.RED)
								
			STATE.E_UNIT_SELECTED_ATTACK:
				#check weapon equipped
				if unitTurn.getEquippedWeapon() != null && unitTurn.validTarget(selectedEnemyUnit):
					attackTurn(unitTurn,selectedEnemyUnit)
					endTurn()
					

	elif Input.is_action_just_pressed("cancel"):
		gridManager.clearUnitSelectionTiles(unitSelectionTiles)
		match curState:
			STATE.CAM_MOVEMENT:
				snapCamMoveToUnit(unitTurn)
				playerInput(unitTurn)
				
			STATE.UNIT_MENU:
				playerUnitGui.hideUnitMenu()
				
				curState = STATE.CAM_MOVEMENT

			STATE.A_UNIT:
				playerUnitGui.hideExpansion()
				playerUnitGui.hideActionBox()
				
				curState = STATE.CAM_MOVEMENT
				
			STATE.UNIT_MOVEMENT_SELECTION:
				playerInput(unitTurn)
				
				curState = STATE.A_UNIT

			STATE.A_UNIT_MOVED:
				unitTurn.setGridPos(unitOriginPos)
				playerInput(unitTurn)
				playerUnitGui.showItem_actionBox(ACTION_BOX_ITEM.MOVE,true)
				
				unitTurn.setAp(apCost.x)
				apCost.y = INF

				updateUnitGridPos()

				curState = STATE.A_UNIT
				
			STATE.ATTACK_MOVEMENT:
				playerInput(unitTurn)
				unitTurnMoved()
				
				enemyUnitGui.hideExpansion()
				playerUnitGui.hideExpansion()

			
			STATE.E_UNIT:
				#when in attack choosing enemy or simply looking at enemy info
				if selectedAllyUnit != null: #ally selected
					pass
				else:
					pass
				pass
			
			STATE.E_UNIT_SELECTED_ATTACK:
				curState = STATE.ATTACK_MOVEMENT
				gridManager.createUnitAttackTiles(unitSelectionTiles,unitTurn.getEquippedWeapon().getRange(),unitTurn.getGridPos())
				
				selectedEnemyUnit = null
				unitTurn.cleanLos()

			

	elif Input.is_action_just_pressed("enlargeTurnOrder"):
		turnManager.enlargeUnitGui()
		
	elif Input.is_action_just_released("enlargeTurnOrder"):
		turnManager.resetUnitGuiScale()
		
	#weapon selection - need to add gui
	elif Input.is_action_pressed("weaponSelection"):
		if Input.is_action_just_pressed("weaponSelection"):
			playerUnitGui.updateWeaponSelect(unitTurn.getWeapons())
			playerUnitGui.selectWeapon(unitTurn.getEquippedWeaponIndex())
			playerUnitGui.showWeaponSelect()
			
			playerUnitGui.hideActionBox()


		if Input.is_action_just_pressed("down") || Input.is_action_just_pressed("up"):
			unitTurn.weaponSelection(Input.get_axis("up","down"))
			playerUnitGui.selectWeapon(unitTurn.getEquippedWeaponIndex())
			
			if curState == STATE.ATTACK_MOVEMENT || curState == STATE.E_UNIT_SELECTED_ATTACK:
				unitSelectionTiles.clear()
				gridManager.createUnitAttackTiles(unitSelectionTiles,unitTurn.getEquippedWeapon().getRange(),unitTurn.getGridPos())

	

	elif Input.is_action_just_released("weaponSelection"):
		#hide gui
		playerUnitGui.hideWeaponSelect()
		if curState == STATE.A_UNIT:
			playerUnitGui.showActionBox()

			
	
#player action menu selection
func _on_menu_select_item_selected(item):
	playerUnitGui.hideActionBox()
	playerUnitGui.hideExpansion()
	match(item):
		"ATTACK":
			curState = STATE.ATTACK_MOVEMENT
			gridManager.createUnitAttackTiles(unitSelectionTiles,unitTurn.getEquippedWeapon().getRange(),unitTurn.getGridPos())

			selectUnitOverlay(unitTurn,unitTurn.getTeam())
			
		"MOVE":
			curState = STATE.UNIT_MOVEMENT_SELECTION
			unitOriginPos = unitTurn.getGridPos()
			gridManager.createUnitMoveTiles(unitSelectionTiles,min(unitTurn.getAp(),unitTurn.getMoveRange()),unitTurn.getGridPos())

		"STATUS":
			curState = STATE.UNIT_MENU
			playerUnitGui.showStatus()
		"ITEM":
			curState = STATE.UNIT_MENU
			playerUnitGui.showUnitItems()
		"END":
			#end unit turn
			endTurn()
			if unitTurn.getTeam() == TEAM.PLAYER:
				curState = STATE.CAM_MOVEMENT
			elif unitTurn.getTeam() == TEAM.ENEMY:
				curState = STATE.NONE
				
		
func snapCamMoveToUnit(unit: BaseUnit ) -> void:
	curState = STATE.CAM_CINEMATIC
	var loc: Vector3 = Vector3(unit.getGridPos().x,battleCam.position.y,unit.getGridPos().y) 
	
	const speed: int = 20
	battleCam.moveToGridPos(loc, speed)
	
	await battleCam.cinematicMoveFinished

	curState = STATE.A_UNIT
	playerUnitGui.showActionBox()
	playerUnitGui.expand()

func attackTurn(attacker: BaseUnit, defender: BaseUnit) -> void:
	curState = STATE.E_UNIT_ATTACK
	attacker.attack(defender)
	await attacker.attackFinished
	
	var attackTimer: Timer = Timer.new()
	add_child(attackTimer)

	#enemy turn
	#ai choose weapon
	defender.setEquippedWeapon(aiManager.getBestWeapon(defender,attacker))
	
	#ai attack
	if defender.getEquippedWeapon() != null && !defender.getBodyparts()[BODYPARTS.BODY].isDestroyed():
		attackTimer.start(0.5)
		await attackTimer.timeout
		defender.attack(attacker)
		await defender.attackFinished
		
	attackTimer.start(2) # might need changing
	await attackTimer.timeout
	
	remove_child(attackTimer)
	attackTimer.queue_free()

	
func gameOver(victory: bool):
	print("game over")
		
func nextTurn() -> void:
	gridManager.clearUnitSelectionTiles(unitSelectionTiles)
	playerUnitGui.showItem_actionBox(ACTION_BOX_ITEM.MOVE,true)
	
	apCost = Vector2.INF
	selectedEnemyUnit = null

	turnManager.nextTurn()

	updateUnitGridPos()
	var unitArray := $battleUnits/playerUnits.get_children() + $battleUnits/enemyUnits.get_children() + $battleUnits/allyUnits.get_children() 

	if turnManager.getTurnNo() > 0:
		for unit in unitArray:
			unit.incTurnTimer()

		if unitTurn != null:
			unitTurn.setTurnTimer(0)

	var order := turnManager.calcTurnOrder(0,unitArray)
	turnManager.updateUnitGuiOrder()

	selectUnit(turnManager.getNextUnit())
	playerTurn = unitTurn.getTeam() == TEAM.PLAYER

	var collisions: Array[Vector2] = []

	if unitTurn.getTeam() == TEAM.PLAYER || unitTurn.getTeam() == TEAM.ALLY:
		unitArray = $battleUnits/enemyUnits.get_children()
		
	else:
		unitArray = $battleUnits/allyUnits.get_children() + $battleUnits/playerUnits.get_children()
		
	for unit in unitArray:
		collisions.append(unit.getGridPos())
		
	astarBoard = gridManager.updateBoardCollisions(collisions)

	if playerTurn:
		curState = STATE.CAM_MOVEMENT

func endTurn() -> void:
	unitTurn.cleanLos()
	curState = STATE.NONE
	if $battleUnits/playerUnits.get_children().size() == 0:
		gameOver(false)

	nextTurn()
	

	

#engine operation
func _ready():
	gridManager.setWorldWalls(mapSize,collisionWalls)
	astarBoard = gridManager.createBoard()
	
	nextTurn()
	updateUnitGridPos()


func _physics_process(delta):
	unitOverlay()
	battleCam.input(!canCamMove(),!canCamRot())
	if curState > STATE.CAM_CINEMATIC && playerTurn :
		input()
		
	$ui/curState.text = "curState: " + str(STATE.find_key(curState))
	
