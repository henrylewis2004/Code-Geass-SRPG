class_name BattleController extends Node

enum STATE{CAM_CINEMATIC, POPUP,UNIT_MENU,NONE,CAM_MOVEMENT, A_UNIT, UNIT_MOVEMENT_SELECTION,ATTACK_MOVEMENT, E_UNIT, BATTLE, A_UNIT_MOVED}
var curState: int = STATE.CAM_MOVEMENT #might need to change to none as default

enum TEAM {PLAYER,ENEMY,ALLY}

@onready var battleCam: BattleCamController = $BattleCam
@onready var playerUnits: Array[Node] = $battleUnits/playerUnits.get_children() 
@onready var enemyUnits: Array[Node] = $battleUnits/enemyUnits.get_children() 
@onready var allyUnits: Array[Node] = $battleUnits/allyUnits.get_children()


@onready var playerUnitGui: AllyUnitGui = $ui/AllyUnitGui 
@onready var turnManager: TurnManager = $TurnManager

#grid
@export var mapSize: Vector2
var gridManager: Grid = Grid.new() 
@onready var collisionWalls := $worldWalls.get_children() 
var astarBoard: AStar2D 

var playerTurn: bool = true
var unitPos: Array[Vector2]

var unitTurn: BaseUnit = null

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
	
	for pos in range(unitPos.size()):
		if unitPos[pos] == camPos:
			if pos < playerUnits.size():
				selectUnitOverlay(playerUnits[pos], TEAM.PLAYER)
				return 

			elif pos < playerUnits.size() + enemyUnits.size():
				selectUnitOverlay(enemyUnits[pos - playerUnits.size()], TEAM.ENEMY)
				return 
			
			else:
				selectUnitOverlay(allyUnits[pos - playerUnits.size() - enemyUnits.size()], TEAM.ALLY)
				return 

	
	playerUnitGui.set_visible(false)

func selectUnitOverlay(unit: BaseUnit, ally: int) -> void: #ally - 0= enemy, 1= player, 2= ally
	if ally == TEAM.PLAYER:
		playerUnitGui.set_visible(true)
		playerUnitGui.updateBase(unit.getName(),unit.getAp(),unit.getCharImage(),unit.getHP())
	
	#add enemy + ally unit overlay


func playerInput(unit: BaseUnit) -> void:
	playerUnitGui.setExpansionInfo(unit.getEquipedWeapon())
	playerUnitGui.expand()
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
							var unitWeapon : Weapon = unit.getEquipedWeapon()

							playerUnitGui.setExpansionInfo(unitWeapon)
							playerUnitGui.expand()
							playerUnitGui.showActionBox()

							curState = STATE.A_UNIT

						
						TEAM.ENEMY: #add enemy units
							print("enemy")

						
						TEAM.ALLY: #add ally units
							print("ally")

			STATE.UNIT_MOVEMENT_SELECTION:
				var unit: BaseUnit = unitInteraction()
				if unit != null:
					#add in unit selection 
					match(unit.getTeam()):
						TEAM.PLAYER:
							if (unitTurn != unit):

								playerUnitGui.expand()
								
								curState = STATE.A_UNIT
						#add enemy units
						TEAM.ENEMY:
							pass
						TEAM.ALLY:
							pass
					
				else: #no unit selected
					var targetLoc: Vector2 = battleCam.getGridPos() #need to add valid location check
					unitTurn.moveTo(gridManager.getASindex(unitTurn.getGridPos()), gridManager.getASindex(targetLoc),astarBoard)
					curState = STATE.CAM_CINEMATIC
					
					#add in camera follow

					await unitTurn.movementFinished
					updateUnitGridPos()
					playerInput(unitTurn)
					
					curState = STATE.A_UNIT_MOVED
					
					
					

				
			STATE.ATTACK_MOVEMENT:
				#add attack orders
				pass

		

	elif Input.is_action_just_pressed("cancel"):
		match curState:
			STATE.CAM_MOVEMENT:
				snapCamMoveToUnit(unitTurn)
				
			STATE.UNIT_MENU:
				playerUnitGui.hideUnitMenu()
				playerUnitGui.showActionBox()
				playerUnitGui.expand()
				
				curState = STATE.A_UNIT

			STATE.A_UNIT:
				selectedAllyUnit = null
				playerUnitGui.hideExpansion()
				playerUnitGui.hideActionBox()
				
				curState = STATE.CAM_MOVEMENT
				
			STATE.UNIT_MOVEMENT_SELECTION:
				playerInput(unitTurn)
				
				curState = STATE.A_UNIT

			STATE.A_UNIT_MOVED:
				unitTurn.setGridPos(unitOriginPos)
				playerInput(unitTurn)

				updateUnitGridPos()

				curState = STATE.A_UNIT
				
			STATE.ATTACK_MOVEMENT:
				playerUnitGui.showActionBox()

				curState = STATE.A_UNIT
			
			STATE.E_UNIT:
				#when in attack choosing enemy or simply looking at enemy info
				if selectedAllyUnit != null: #ally selected
					pass
				else:
					pass
				pass
			

	elif Input.is_action_just_pressed("nextUnit") || Input.is_action_just_pressed("previousUnit"):
		selectNextUnit(Input.get_axis("previousUnit","nextUnit"))
			
	
#player action menu selection
func _on_menu_select_item_selected(item):
	playerUnitGui.hideActionBox()
	playerUnitGui.hideExpansion()
	match(item):
		"ATTACK":
			curState = STATE.ATTACK_MOVEMENT
		"MOVE":
			curState = STATE.UNIT_MOVEMENT_SELECTION
			unitOriginPos = unitTurn.getGridPos()

		"STATUS":
			curState = STATE.UNIT_MENU
			playerUnitGui.showStatus()
		"ITEM":
			curState = STATE.UNIT_MENU
			playerUnitGui.showUnitItems()
		"END":
			#end unit turn
			nextTurn()
			playerTurn = false
			if unitTurn.getTeam() == TEAM.PLAYER:
				curState = STATE.CAM_MOVEMENT
				playerTurn = true
			elif unitTurn.getTeam() == TEAM.ENEMY:
				curState = STATE.NONE
				
		
func snapCamMoveToUnit(unit: BaseUnit ) -> void:
	curState = STATE.CAM_CINEMATIC
	var loc: Vector3 = Vector3(unit.getGridPos().x,battleCam.position.y,unit.getGridPos().y) 
	print(unitTurn.getGridPos())
	print(loc)
	
	const speed: int = 20
	battleCam.moveToGridPos(loc, speed)
	
	await battleCam.cinematicMoveFinished
	print(battleCam.getGridPos())

	curState = STATE.A_UNIT
	playerUnitGui.showActionBox()
	playerUnitGui.expand()

	
func gameOver(victory: bool):
	print("game over")
		
func nextTurn() -> void:
	turnManager.nextTurn()
	if $battleUnits/playerUnits.get_children().size() == 0:
		gameOver(false)

	updateUnitGridPos()
	var unitArray := $battleUnits/playerUnits.get_children() + $battleUnits/enemyUnits.get_children() + $battleUnits/allyUnits.get_children() 
	var collisions: Array[Vector2]
	
	for unit in unitArray:
		collisions.append(unit.getGridPos())
		
	astarBoard = gridManager.createBoard(collisions)
	

	if turnManager.getTurnNo() > 0:
		for unit in unitArray:
			unit.incTurnTimer()

		if selectedAllyUnit != null:
			unitTurn.setTurnTimer(0)

	var order := turnManager.calcTurnOrder(0,unitArray)
	turnManager.updateUnitGuiOrder()
	selectUnit(turnManager.getNextUnit())

#engine operation
func _ready():
	gridManager.setWorldWalls(mapSize,collisionWalls)
	nextTurn()
	updateUnitGridPos()


func _physics_process(delta):
	unitOverlay()
	battleCam.input(!canCamMove(),!canCamRot())
	input()
	
