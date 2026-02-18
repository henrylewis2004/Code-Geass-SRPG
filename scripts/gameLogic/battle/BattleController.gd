class_name BattleController extends Node

signal sceneOver
signal resetScene

signal unitDeath_finished

signal inputTaken
signal actionComplete

const STATE := preload("res://resources/scripts/enumClasses/ENUMstates.gd").BATTLESTATE
var curState: int = STATE.NONE #might need to change to none as default

enum TEAM {PLAYER,ENEMY,ALLY}
enum UNIT_SELECT_TILE{MOVE,ATTACK,INTERACT}
const ACTION_BOX_ITEM := preload("res://resources/scripts/enumClasses/ENUM_actionBoxOptions.gd").ACTION_BOX_ITEM
const BODYPARTS := preload("res://resources/scripts/enumClasses/ENUMbodyparts.gd").BODYPARTS
const SELECTION_TILE_ID := preload("res://resources/scripts/enumClasses/ENUM_unitSelectionTiles.gd").SELECTION_TILES_ID


@onready var battleCam: BattleCamController = $BattleCam
@onready var playerUnits: Array[BaseUnit] = getUnits($battleUnits/playerUnits.get_children() )
@onready var enemyUnits: Array[BaseUnit] = getUnits($battleUnits/enemyUnits.get_children() )
@onready var allyUnits: Array[BaseUnit] = getUnits( $battleUnits/allyUnits.get_children())

#gridmap
@onready var gridMapCol: GridMap = $Grid/world_gridmap_col
#@onready var gridMap_noCol: GridMap = $Grid/world_gridmap_noCOL


@onready var playerUnitGui: AllyUnitGui = $ui/AllyUnitGui 
@onready var enemyUnitGui: BattleUnitGui  = $ui/EnemyUnitGui
@onready var statusScreen: UnitStatusScreen = $ui/StatusScreen

@onready var turnManager: TurnManager = $TurnManager
@onready var drawManager: DrawManager = $ui/DrawManager

@onready var gameOverMan: GameOverManager = $GameOver
@onready var newTurnGraphic: Control = $ui/NewTurn

#music
@onready var music_sfxPlayer: AudioStreamPlayer = $audio/sfx/sfx_ui
@onready var music_musicPlayer: AudioStreamPlayer = $audio/music/bkg_music

const sfx_select: String = "res://assets/sfx/sfx/ds_sfx/select05.wav"


var aiManager : AiManager = AiManager.new()
@onready var animPlayer: AnimationPlayer = $animation/AnimationPlayer
@onready var itemAbMan : ItemAbilityManager = ItemAbilityManager.new(animPlayer)

var apCost: Vector2 = Vector2.INF #x = ap at start of turn, y = ap after move, then final ap taken in attack phase and turn ends

#grid
@export var mapSize: Vector2
var gridManager: BattleGrid = BattleGrid.new() 

@onready var collisionWalls := $Grid/worldWalls.get_children() 
var astarBoard: AStar2D 

@onready var unitSelectionTiles : GridMap = $Grid/unitSelection
#

var playerTurn: bool = true
var unitPos: Array[Vector2]

#units
var unitTurn: BaseUnit = null
var selectedEnemyUnit: BaseUnit = null
#selection
var selectedAllyUnit
#activies 
var selectedActivity: BaseItem = null
var selectedActivityUnit: BaseUnit = null

#ui units
var primaryUnit_ui: BaseUnit = null
var targetUnit_ui: BaseUnit = null
var activity_ui: BaseItem = null

var unitOriginPos: Vector2 = Vector2.INF

var utilFun: Util = Util.new()
var attackAnimMan : AttackAnimationManager = AttackAnimationManager.new()

#methods
func getUnits(unitArray: Array[Node]) -> Array[BaseUnit]:
	var arr : Array[BaseUnit] = []

	for unit in unitArray:
		arr.append(unit.get_child(0))

	return arr


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
	return (
		curState == STATE.CAM_MOVEMENT 
		|| curState == STATE.UNIT_MOVEMENT_SELECTION 
		|| curState == STATE.ATTACK_MOVEMENT 
		|| curState == STATE.A_UNIT_ITEM_PREV 
		)

func canCamRot() -> bool:
	return !(
		curState == STATE.NONE 
		|| curState == STATE.BATTLE
		|| curState == STATE.GAME_OVER
		|| curState == STATE.E_UNIT_CAM_CINEMATIC
		)

#weapon selection
func showWeaponSelection() -> bool:
	return !(
		curState == STATE.UNIT_MENU_PLAYER 
		|| curState == STATE.UNIT_MENU_ENEMY 
		|| curState == STATE.UNIT_MENU_ALLY
		)

#unit overlay
func showPlayerUnit() -> bool :
	return (
		curState ==  STATE.A_UNIT_CAM_CINEMATIC 
		|| curState ==  STATE.E_UNIT_CAM_CINEMATIC 
		|| curState == STATE.UNIT_MOVEMENT_SELECTION 
		|| curState == STATE.ATTACK_MOVEMENT 
		|| curState == STATE.A_UNIT_ITEM_PREV 
		|| curState == STATE.A_UNIT_PART_SELECT
		)
		
func showAttackOverlay() -> bool :
	return (
		curState ==  STATE.BATTLE 
		|| curState == STATE.E_UNIT_SELECTED_ATTACK 
		|| curState == STATE.E_UNIT_ATTACK_WPN_SELECTION
		)		
	

func showUnitOverlay() -> bool :
	return !( 
		curState == STATE.UNIT_MENU_PLAYER 
		|| curState == STATE.UNIT_MENU_ENEMY 
		|| curState == STATE.UNIT_MENU_ALLY
		|| curState == STATE.GAME_OVER
		)

func unitOverlay() -> void:
	var camPos: Vector2 = battleCam.getGridPos()
	playerUnitGui.hideBase()
	enemyUnitGui.hideBase()
	
	if showUnitOverlay():
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
		
	if showAttackOverlay():		
		if unitTurn != null:
			selectUnitOverlay(unitTurn,unitTurn.getTeam())
		if selectedEnemyUnit != null:
			selectUnitOverlay(selectedEnemyUnit,selectedEnemyUnit.getTeam())

		
	unitOverlayAttack()
	unitOverlayItem()
	

func set_unitOverlay(primary_unit:BaseUnit,target_unit: BaseUnit, activity: BaseItem = null) -> void:
	primaryUnit_ui = primary_unit
	targetUnit_ui = target_unit
	activity_ui = activity
	
	if primary_unit != null:
		var colour: Color = Color.RED

		if activity_ui != null:
			colour = Color.DEEP_PINK
			if activity_ui is BattleItem:
				colour = Color.YELLOW

		drawManager.drawLosLine(primaryUnit_ui.position,targetUnit_ui.position,colour,drawManager.defaultLinePos)
	
		
func unitOverlayAttack() -> void:
	if curState == STATE.E_UNIT_SELECTED_ATTACK || curState == STATE.E_UNIT_ATTACK_WPN_SELECTION:
		var unit: BaseUnit = primaryUnit_ui if primaryUnit_ui.getTeam() == TEAM.PLAYER else targetUnit_ui
		var e_unit: BaseUnit = targetUnit_ui if primaryUnit_ui.getTeam() == TEAM.PLAYER else primaryUnit_ui 
		var text: String
		if unit.getEquippedWeapon() == null: 
			text = "X\nNO COUNTER"
			drawManager.drawAccText(unit.position,e_unit.position,text, Color.RED,drawManager.defaultTextPos)
			return
		else: text = str(unit.getEquippedWeapon().getAccuracy()) + "%"
		if unit.getAp() < unit.getEquippedWeapon().getApCost(): text = "X\nNO AP"
		if gridManager.absDist(e_unit.getGridPos(),unit.getGridPos()) > unit.getEquippedWeapon().getRange(): text = "X\nOUT OF\nRANGE"
		if !unit.hasLOS(e_unit): text = "X\nNO LOS"

		drawManager.drawAccText(unit.position,e_unit.position,text, Color.RED,drawManager.defaultTextPos)
		
func unitOverlayItem() -> void:
	if curState == STATE.A_UNIT_ITEM || curState == STATE.A_UNIT_PART_SELECT:
		var text: String = activity_ui.getName()
		if primaryUnit_ui.getAp() < activity_ui.getApCost(): text = "NO AP"
		if itemAbMan.itemDistUse(primaryUnit_ui.getGridPos(),targetUnit_ui.getGridPos()) > activity_ui.getRange(): text = "OUT OF\nRANGE"

		if activity_ui is Ability:
			if primaryUnit_ui.getEnergy() < activity_ui.getEnergyCost(): text = "NO ENERGY"

		drawManager.drawAccText(primaryUnit_ui.position,targetUnit_ui.position,text, Color.RED,Vector3(0.5,1.3,0.5))

func selectUnitOverlay(unit: BaseUnit, team: int) -> void: #team : 0= enemy, 1= player, 2= ally
	if team == TEAM.PLAYER:
		playerUnitGui.updateBase(unit.getName(),unit.getAp(),unit.getCharImage(),unit.getHP())
		playerUnitGui.showBase()
		
		if curState == STATE.ATTACK_MOVEMENT || showAttackOverlay():
			playerUnitGui.setExpansionInfo(unit.getEquippedWeapon())
			playerUnitGui.expand()
	
	elif team == TEAM.ENEMY:
		enemyUnitGui.updateBase(unit.getName(),unit.getAp(),unit.getCharImage(),unit.getHP())
		enemyUnitGui.showBase()

		if curState == STATE.E_UNIT || showAttackOverlay() || curState == STATE.ATTACK_MOVEMENT:
			enemyUnitGui.setExpansionInfo(unit.getEquippedWeapon())
			enemyUnitGui.expand()
	
	#add enemy + ally unit overlay

func playerInput(unit: BaseUnit) -> void:
	playerUnitGui.showActionBox(unit.getItems().size() > 0, unit.getAbilities().size() > 0)
	
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

	
func selectUnit(unit: BaseUnit) -> void:#needs modification
	unitTurn = unit
	battleCam.snapToGridPos(unit.getGridPos())
	
	
	
func unitTurnMoved() -> void:
	if unitTurn.getGridPos() != unitOriginPos && unitOriginPos != Vector2.INF:
		curState = STATE.A_UNIT_MOVED
		playerUnitGui.showItem_actionBox(ACTION_BOX_ITEM.MOVE,false)
		return
	curState = STATE.A_UNIT
	playerUnitGui.showActionBox(unitTurn.getItems().size() > 0, unitTurn.getAbilities().size() > 0)
	
func moveUnit(unit: BaseUnit, mov_position: Vector2) -> void:
	gridManager.setPosition_occupied(mov_position,unit.getGridPos())
	unit.moveTo(gridManager.getASindex(unit.getGridPos()),gridManager.getASindex(mov_position),astarBoard)
	

#use items
func useItemAbility(unit: BaseUnit, targetUnit: BaseUnit, activity: BaseItem, selectedBodyPart = -1) -> void:
	#check valid 

	if selectedActivity is Ability && !itemAbMan.validAbility(unit,targetUnit,activity):
		return 

	if selectedActivity is BattleItem && !itemAbMan.validItem(unit,targetUnit,activity):
		return 

	playerUnitGui.hideItems()
	drawManager.cleanLos()
	curState = STATE.A_UNIT_ITEM_ACTION
	set_unitOverlay(null,null,null)


	if selectedActivity is Ability:
		itemAbMan.useAbility(selectedActivity,unitTurn,selectedActivityUnit, selectedBodyPart)

		turnManager.itemAbUsed(itemAbMan.getAbilityTimeCost(selectedActivity.getID()))

	else:
		itemAbMan.useItem(selectedActivity,unitTurn,selectedActivityUnit,selectedBodyPart)

		turnManager.itemAbUsed(itemAbMan.getItemTimeCost(selectedActivity.getID()))



func itemEndTurn(ability: bool) -> void:
	endTurn()
	
func wpnSelection(input: int,unit:BaseUnit = unitTurn,noCounter:bool = false) -> void:
	if noCounter:
		var wpnSize: int = unit.getWeapons().size() - 1
		match(unit.getEquippedWeaponIndex()):
			0:
				if input < 0:
					unit.setEquippedWeapon(-1)
					playerUnitGui.selectWeapon(0)
					gridManager.clearUnitSelectionTiles(unitSelectionTiles)
					return


			wpnSize:
				if input > 0:
					unit.setEquippedWeapon(-1)
					playerUnitGui.selectWeapon(0)
					gridManager.clearUnitSelectionTiles(unitSelectionTiles)
					return

	unit.weaponSelection(input)
	playerUnitGui.selectWeapon(unit.getEquippedWeaponIndex() + 1 * int(noCounter))
	
	if curState == STATE.ATTACK_MOVEMENT || curState == STATE.E_UNIT_SELECTED_ATTACK || curState == STATE.E_UNIT_ATTACK_WPN_SELECTION:
		unitSelectionTiles.clear()
		if unit.getEquippedWeapon() != null:
			gridManager.createUnitAttackTiles(unitSelectionTiles,unit.getEquippedWeapon().getRange(),unit.getGridPos())
		else:
			gridManager.clearUnitSelectionTiles(unitSelectionTiles)
	
#handles player input
func input() -> void:
	if Input.is_action_just_pressed("reload_level"):
		resetScene.emit()

	if Input.is_action_just_pressed("accept"):
		match (curState):
			STATE.CAM_MOVEMENT:
				var unit: BaseUnit = unitInteraction()
				if unit != null:
					match(unit.getTeam()):
						TEAM.PLAYER: #player unit
							#needs rework
							if unit == unitTurn:
								playerUnitGui.showActionBox(unitTurn.getItems().size() > 0, unitTurn.getAbilities().size() > 0)
								battleCam.snapToGridPos(unitTurn.getGridPos())

								curState = STATE.A_UNIT

							else:
								curState = STATE.UNIT_MENU_ALLY
								battleCam.snapToGridPos(unit.getGridPos())

								#draw ui
								statusScreen.showStatus(unit)

						
						TEAM.ENEMY: #add enemy units
							curState = STATE.UNIT_MENU_ENEMY
							battleCam.snapToGridPos(unit.getGridPos())

							#draw ui
							statusScreen.showStatus(unit)

						
						TEAM.ALLY: #add ally units
							curState = STATE.UNIT_MENU_ALLY

							#draw ui
							statusScreen.showStatus(unit)

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
					var targetLoc: Vector2 = battleCam.getGridPos() 
					if gridManager.validMove(targetLoc,unitTurn):
						music_sfxPlayer.set_stream(load(sfx_select))
						music_sfxPlayer.play()



						unitTurn.incAp(-gridManager.apMoveCost(unitTurn.getGridPos(),targetLoc))
						apCost.y = unitTurn.getAp()

						gridManager.clearUnitSelectionTiles(unitSelectionTiles)

						curState = STATE.A_UNIT_CAM_CINEMATIC
						moveUnit(unitTurn,targetLoc)
						battleCam.followUnit(unitTurn)
						
						await unitTurn.movementFinished

						updateUnitGridPos()
						#probably dont need anymore
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
								gridManager.clearUnitSelectionTiles(unitSelectionTiles)
								unitTurnMoved()
								playerInput(unitTurn)
						TEAM.ALLY:
							pass

						TEAM.ENEMY:
							#valid target - loc and range
							curState = STATE.E_UNIT_SELECTED_ATTACK
							battleCam.snapToGridPos(unit.getGridPos())
							
							selectedEnemyUnit = unit
							set_unitOverlay(unitTurn,unit)
							
							#add line between uints - maybe add to unit code 
							gridManager.clearUnitSelectionTiles(unitSelectionTiles)
							drawManager.drawLosLine(unitTurn.position,selectedEnemyUnit.position, Color.RED,drawManager.defaultLinePos)
								
			STATE.E_UNIT_SELECTED_ATTACK:
				#check weapon equipped
				if unitTurn.getEquippedWeapon() != null && unitTurn.validTarget(selectedEnemyUnit) && unitTurn.hasLOS(selectedEnemyUnit):
					attackTurn(unitTurn,selectedEnemyUnit)
					await actionComplete
					endTurn()
					
			STATE.A_UNIT_ITEM_PREV:
				#use item
				var unit: BaseUnit = unitInteraction()
				if unit != null:
					curState = STATE.A_UNIT_ITEM
					selectedActivityUnit = unit
					
					set_unitOverlay(unitTurn,selectedActivityUnit,selectedActivity)

					var colour: Color = Color.DEEP_PINK
					if selectedActivity is BattleItem:
						colour = Color.YELLOW
						
					if selectedActivity.isSinglePart():
						#select part to affect
						curState = STATE.A_UNIT_PART_SELECT
						playerUnitGui.partSelectPos(unit.getTeam() != unitTurn.getTeam())
						playerUnitGui.showPartSelection(unit.getAliveBodyparts())
						

					drawManager.drawLosLine(unitTurn.position,unit.position,colour,drawManager.defaultLinePos)

###

		########
					
					battleCam.snapToGridPos(unit.getGridPos())
					gridManager.clearUnitSelectionTiles(unitSelectionTiles)
					
			STATE.A_UNIT_ITEM:
				if selectedActivityUnit != null:
					useItemAbility(unitTurn,selectedActivityUnit,selectedActivity)
					
			STATE.E_UNIT_ATTACK_WPN_SELECTION:
				if selectedEnemyUnit.getEquippedWeaponIndex() < 0 || (selectedEnemyUnit.validTarget(unitTurn)):
					inputTaken.emit()


	elif Input.is_action_just_pressed("cancel"):
		match curState:
			STATE.CAM_MOVEMENT:
				snapCamMoveToUnit(unitTurn)
				playerInput(unitTurn)
				curState = STATE.A_UNIT
				
			STATE.UNIT_MENU_PLAYER:
				statusScreen.hideStatus()
				
				playerUnitGui.showActionBox(unitTurn.getItems().size() > 0, unitTurn.getAbilities().size() > 0)
				unitTurnMoved()

			STATE.UNIT_MENU_ALLY:
				statusScreen.hideStatus()
				
				#snapCamMoveToUnit(unitTurn)
				#unitTurnMoved()
				curState = STATE.CAM_MOVEMENT

			STATE.UNIT_MENU_ENEMY:
				statusScreen.hideStatus()

			#	snapCamMoveToUnit(unitTurn)
			#	unitTurnMoved()
				curState = STATE.CAM_MOVEMENT

			STATE.A_UNIT:
				playerUnitGui.hideExpansion()
				playerUnitGui.hideActionBox()
				
				curState = STATE.CAM_MOVEMENT

			STATE.A_UNIT_MENU_ITEM:
				playerUnitGui.hideItems()
				playerUnitGui.showActionBox(unitTurn.getItems().size() > 0, unitTurn.getAbilities().size() > 0)
				unitTurnMoved()

				
			STATE.UNIT_MOVEMENT_SELECTION:
				gridManager.clearUnitSelectionTiles(unitSelectionTiles)
				
				playerInput(unitTurn)
				curState = STATE.A_UNIT

			STATE.A_UNIT_MOVED:
				gridManager.setPosition_occupied(unitOriginPos,unitTurn.getGridPos())
				unitTurn.setGridPos(unitOriginPos)
				
				playerInput(unitTurn)
				playerUnitGui.showItem_actionBox(ACTION_BOX_ITEM.MOVE,true)
				
				unitTurn.setAp(apCost.x)
				apCost.y = INF

				updateUnitGridPos()

				curState = STATE.A_UNIT
				
			STATE.ATTACK_MOVEMENT:
				gridManager.clearUnitSelectionTiles(unitSelectionTiles)
				
				playerInput(unitTurn)
				unitTurnMoved()
				
				enemyUnitGui.hideExpansion()
				playerUnitGui.hideExpansion()


			STATE.A_UNIT_ITEM_PREV:
				gridManager.clearUnitSelectionTiles(unitSelectionTiles)
				
				curState = STATE.A_UNIT_MENU_ITEM
				playerInput(unitTurn)

				playerUnitGui.hideItems()
				if selectedActivity is Ability:
					playerUnitGui.showUnitAbilities(unitTurn.getAbilities())

				else:
					playerUnitGui.showUnitItems(unitTurn.getItems())

				selectedActivity = null



			STATE.A_UNIT_ITEM:
				curState = STATE.A_UNIT_ITEM_PREV
				gridManager.createItemPrevTiles(unitSelectionTiles,selectedActivity.getRange(),unitTurn.getGridPos(),(selectedActivity is Ability && selectedActivity.isAttack()))
				
				selectedActivityUnit = null
				set_unitOverlay(null,null,null)
				drawManager.cleanLos()
				
			STATE.A_UNIT_PART_SELECT:
				curState = STATE.A_UNIT_ITEM_PREV
				gridManager.createItemPrevTiles(unitSelectionTiles,selectedActivity.getRange(),unitTurn.getGridPos(),(selectedActivity is Ability && selectedActivity.isAttack()))
				playerUnitGui.hideItems()
				
				selectedActivityUnit = null


			
			STATE.E_UNIT:
				#when in attack choosing enemy or simply looking at enemy info
				pass
			
			STATE.E_UNIT_SELECTED_ATTACK:
				
				curState = STATE.ATTACK_MOVEMENT
				if unitTurn.getEquippedWeapon() != null:
					gridManager.createUnitAttackTiles(unitSelectionTiles,unitTurn.getEquippedWeapon().getRange(),unitTurn.getGridPos())
				
				set_unitOverlay(null,null,null)
				
				selectedEnemyUnit = null
				drawManager.cleanLos()
	
	

			

	elif Input.is_action_just_pressed("enlargeTurnOrder"):
		turnManager.enlargeUnitGui()
		
	elif Input.is_action_just_released("enlargeTurnOrder"):
		turnManager.resetUnitGuiScale()
		
	#weapon selection - need to add gui
	elif Input.is_action_pressed("weaponSelection"):
		if showWeaponSelection():
			if Input.is_action_just_pressed("weaponSelection"):
				playerUnitGui.updateWeaponSelect(unitTurn.getWeapons(),unitTurn.getEquippedWeaponIndex())


			if Input.is_action_just_pressed("down") || Input.is_action_just_pressed("up"):
				wpnSelection(Input.get_axis("up","down"))

	elif curState == STATE.E_UNIT_ATTACK_WPN_SELECTION:
		
		if Input.is_action_just_pressed("down") || Input.is_action_just_pressed("up"):
			wpnSelection(Input.get_axis("up","down"),selectedEnemyUnit,true)

	

	elif Input.is_action_just_released("weaponSelection"):
		#hide gui
		playerUnitGui.hideWeaponSelect()
		if curState == STATE.A_UNIT:
			playerUnitGui.showActionBox(unitTurn.getItems().size() > 0, unitTurn.getAbilities().size() > 0)

	#status Screen
	elif Input.is_action_just_released("nextUnit") || Input.is_action_just_released("previousUnit"):
	#	match(curState):
	#		STATE.UNIT_MENU_PLAYER:
		statusScreen.goToNextPage(int(Input.is_action_just_released("nextUnit")) - int(Input.is_action_just_released("previousUnit")))
			
	
#player action menu selection
func _on_menu_select_item_selected(item):
	playerUnitGui.hideItems()
	playerUnitGui.hideExpansion()
	match(item):
		"ATTACK":
			curState = STATE.ATTACK_MOVEMENT
			if unitTurn.getEquippedWeapon() != null:
				gridManager.createUnitAttackTiles(unitSelectionTiles,unitTurn.getEquippedWeapon().getRange(),unitTurn.getGridPos())
			else:
				gridManager.clearUnitSelectionTiles(unitSelectionTiles)

			selectUnitOverlay(unitTurn,unitTurn.getTeam())
			
		"MOVE":
			curState = STATE.UNIT_MOVEMENT_SELECTION
			unitOriginPos = unitTurn.getGridPos()
			gridManager.createUnitMoveTiles(unitSelectionTiles,unitTurn.getMoveRange(),unitTurn.getGridPos())

		"STATUS":
			curState = STATE.UNIT_MENU_PLAYER

			#change to selectedunit
			statusScreen.updateAll(unitTurn)
			statusScreen.showStatus(unitTurn)

		"ITEMS":
			curState = STATE.A_UNIT_MENU_ITEM
			playerUnitGui.showUnitItems(unitTurn.getItems())
		"ABILITY":
			curState = STATE.A_UNIT_MENU_ITEM
			playerUnitGui.showUnitAbilities(unitTurn.getAbilities())
		"END":
			#end unit turn
			endTurn()
				

#items and abliities - items
func _on_menu_select_battle_item_selected(itemKey,isItem):
	match(itemKey):
		-1: #cancel
			playerUnitGui.hideItems()
			playerUnitGui.showActionBox(unitTurn.getItems().size() > 0, unitTurn.getAbilities().size() > 0)

			curState = STATE.A_UNIT
		-2:
			pass
		_:
			curState = STATE.A_UNIT_ITEM_PREV
			playerUnitGui.hideItems()

			var item: BaseItem
			if !isItem:
				item = unitTurn.getAbilities()[itemKey]
			else:
				item = unitTurn.getItems()[itemKey]

			selectedActivity = item

			gridManager.createItemPrevTiles(unitSelectionTiles,item.getRange(),unitTurn.getGridPos(),(item is Ability && item.isAttack()))
			


func _on_menu_select_part_selected(partId):
	match (partId):
		-1:
			playerUnitGui.showPartSelection(selectedActivityUnit.getBodyparts())
		-2:
			pass
		_:
			useItemAbility(unitTurn,selectedActivityUnit,selectedActivity,partId)
			

		
#utility methods
func snapCamMoveToUnit(unit: BaseUnit ) -> void:
	curState = STATE.CAM_CINEMATIC
	var loc: Vector3 = Vector3(unit.getGridPos().x,battleCam.position.y,unit.getGridPos().y) 
	
	const speed: int = 20
	battleCam.moveToGridPos(loc, speed)
	
	await battleCam.cinematicMoveFinished



func attackTurn(attacker: BaseUnit, defender: BaseUnit) -> void:
	curState = STATE.BATTLE
	
	drawManager.cleanLos()

	battleCam.moveToGridPos(Vector3(defender.getGridPos().x,0,defender.getGridPos().y), 5)
	await battleCam.cinematicMoveFinished

	#ai choose weapon
	if defender.getTeam() == TEAM.ENEMY:
		defender.setEquippedWeapon(aiManager.getBestWeapon(defender,attacker,gridManager))

	var attackTimer: Timer = Timer.new()
	add_child(attackTimer)

	attackTimer.start(0.5)
	await attackTimer.timeout
	


	if attacker.getEquippedWeapon() != null:
	#	curState = STATE.BATTLE
		attacker.connect("attack_landed",attackGFX)
		attacker.attack(defender,attackAnimMan.getWeaponAnim(attacker.getEquippedWeapon().getWeaponID()))
		await attacker.attackFinished
		attacker.disconnect("attack_landed",attackGFX)

	
	attackTimer.start(0.5)
	await attackTimer.timeout
	hideAttackGFX()

	turnManager.unitAttacked(attacker.getEquippedWeapon().getWeaponID())

	#enemy turn
	#check if dead
	if !defender.isDestroyed():
		battleCam.moveToGridPos(Vector3(attacker.getGridPos().x,0,attacker.getGridPos().y),5)
		await battleCam.cinematicMoveFinished
		#ai attack
		if defender.getEquippedWeapon() != null && defender.getAp() >= defender.getEquippedWeapon().getApCost():
			attackTimer.start(0.5)
			await attackTimer.timeout
			defender.connect("attack_landed",attackGFX)
			defender.attack(attacker,attackAnimMan.getWeaponAnim(defender.getEquippedWeapon().getWeaponID()))
			await defender.attackFinished
			defender.disconnect("attack_landed",attackGFX)

			attackTimer.start(0.5)
			await attackTimer.timeout
			hideAttackGFX()

			defender.incTurnTimer(turnManager.getAttackTimeCost(defender.getEquippedWeapon().getWeaponID(),true))

			if attacker.isDestroyed():
				killUnit(attacker)
				await unitDeath_finished

				attackTimer.start(1)
				await attackTimer.timeout

				battleCam.moveToGridPos(Vector3(defender.getGridPos().x,0,defender.getGridPos().y),5 * 2)
				await battleCam.cinematicMoveFinished

				attackTimer.start(0.5) # might need changing
				await attackTimer.timeout

			else:
				battleCam.moveToGridPos(Vector3(attacker.getGridPos().x,0,attacker.getGridPos().y),5 * 2)
				await battleCam.cinematicMoveFinished

				attackTimer.start(0.5) # might need changing
				await attackTimer.timeout


	else:
		killUnit(defender)
		await unitDeath_finished

		attackTimer.start(1) # might need changing
		await attackTimer.timeout

		battleCam.moveToGridPos(Vector3(attacker.getGridPos().x,0,attacker.getGridPos().y),5 * 2)
		await battleCam.cinematicMoveFinished

		attackTimer.start(0.5) # might need changing
		await attackTimer.timeout
		
	
	remove_child(attackTimer)
	attackTimer.queue_free()
	set_unitOverlay(null,null,null)

	actionComplete.emit()
	

func attackGFX(landed: bool) ->void:
	print(landed)
	for control in $animation/AttackMiss.get_children():
		for label in control.get_children():
			label.text = "HIT" if landed else "MISS"

	animPlayer.play("RESET")
	animPlayer.play("attack_miss")

func hideAttackGFX() -> void:
	animPlayer.play("RESET")



func killUnit(unit: BaseUnit) -> void:
	animPlayer.play("unitDeath")
	await animPlayer.animation_finished


	match unit.getTeam():
		TEAM.PLAYER: 
			playerUnits.erase(unit)
		TEAM.ENEMY : 
			enemyUnits.erase(unit)
		TEAM.ALLY  : 
			allyUnits.erase(unit)

	updateUnitGridPos()
	unit.kill()


func aiAttackTurn(unit:BaseUnit, targetUnit: BaseUnit) -> void:
	#add los 
	

	curState = STATE.E_UNIT_ATTACK_WPN_SELECTION
	selectedEnemyUnit = targetUnit
	selectedEnemyUnit.setEquippedWeapon(-1)
	playerUnitGui.updateWeaponSelect(targetUnit.getWeapons(),selectedEnemyUnit.getEquippedWeaponIndex(),true)
	
	set_unitOverlay(unit,targetUnit)

	await inputTaken
	playerUnitGui.hideWeaponSelect()
	gridManager.clearUnitSelectionTiles(unitSelectionTiles)
	
	attackTurn(unit,targetUnit)
	await actionComplete
	curState = STATE.NONE
	
	aiManager.actionComplete_timeout()
	
	

	
func gameOver(victory: bool):
	curState = STATE.GAME_OVER
	unitOverlay()
	gameOverMan.gameOver(victory)


func endLevel(nextScene: bool) -> void:
	if nextScene: 
		sceneOver.emit()
		return
	resetScene.emit()


	#add animation of game over 
func newTurnGFX(player: bool, character_name: String) -> void:
	var text: String = "- [color=green]PLAYER[/color] TURN -"
	var sfx: String = "res://assets/sfx/sfx/ds_sfx/select06.wav"
	if !player: 
		text = "- [color=red]ENEMY[/color] TURN -"
		sfx = "res://assets/sfx/sfx/ds_sfx/select07.wav"

	newTurnGraphic.get_node("Label").text = text + "\n" + character_name
	
	music_sfxPlayer.set_stream(load(sfx))
	music_sfxPlayer.play()

	animPlayer.play("newTurn")
	await animPlayer.animation_finished
	animPlayer.play("RESET")
		
func nextTurn() -> void:
	gridManager.clearUnitSelectionTiles(unitSelectionTiles)
	playerUnitGui.showMoveOption(true)
	
	curState = STATE.NONE
	apCost = Vector2.INF 
	selectedEnemyUnit = null
	selectedActivityUnit = null
	selectedActivity = null
	turnManager.resetTurnCost()

	updateUnitGridPos()
	var unitArray := getUnits($battleUnits/playerUnits.get_children()) + getUnits($battleUnits/enemyUnits.get_children()) + getUnits($battleUnits/allyUnits.get_children() )

	turnManager.createTurnOrder(unitArray)
	selectUnit(turnManager.getNextUnit())
	unitTurn.newTurn()
	apCost.x = unitTurn.getAp()
	
	playerTurn = unitTurn.getTeam() == TEAM.PLAYER
	playerUnitGui.updateBase(unitTurn.getName(),unitTurn.getAp(),unitTurn.getCharImage(),unitTurn.getHP())

	var collisions: Array[Vector2] = gridManager.getGridPos_fromV3_Array(gridMapCol.get_used_cells())
	newTurnGFX(playerTurn,unitTurn.getName())
	await animPlayer.animation_finished

	if unitTurn.getTeam() == TEAM.PLAYER || unitTurn.getTeam() == TEAM.ALLY:
		unitArray = getUnits($battleUnits/enemyUnits.get_children())
	else:
		unitArray = getUnits($battleUnits/allyUnits.get_children() + $battleUnits/playerUnits.get_children())
		
	for unit in unitArray:
		collisions.append(unit.getGridPos())
		
	astarBoard = gridManager.updateBoardCollisions(collisions)

	unitOriginPos = unitTurn.getGridPos()

	if playerTurn:
		curState = STATE.CAM_MOVEMENT
		
		if unitTurn.getEquippedWeapon() == null:
			unitTurn.equipAWeapon()
	
	else:
		var timer: Timer = Timer.new()
		add_child(timer)

		timer.start(0.5)
		await timer.timeout

		aiManager.getTurn(unitTurn,$battleUnits/enemyUnits.get_children(),getUnits($battleUnits/allyUnits.get_children() + $battleUnits/playerUnits.get_children()),gridManager,battleCam,itemAbMan)
		await aiManager.turnFinished

		timer.start(0.5)
		await timer.timeout

		endTurn()

func endTurn() -> void:
	drawManager.cleanLos()
	
	
	if $battleUnits/playerUnits.get_children().size() == 0:
		gameOver(false)
		return
	if $battleUnits/enemyUnits.get_children().size() == 0:
		gameOver(true)
		return

	if unitTurn != null:
		#take unit time away
		turnManager.unitMoved(gridManager.absDist(unitTurn.getGridPos(),unitOriginPos))

		print(unitTurn.getName()+  " b: " + str(unitTurn.getTurnTimer()))
		unitTurn.incTurnTimer(turnManager.getTurnCost() * -1) 
		print(unitTurn.getName()+  " a: " + str(unitTurn.getTurnTimer()))
		unitTurn.setMoved(true)


	nextTurn()
	

func updateOccupiedMapGrid() -> void:
	for unit in playerUnits:
		gridManager.setPosition_occupied(unit.getGridPos())

	for unit in enemyUnits:
		gridManager.setPosition_occupied(unit.getGridPos())

	for unit in allyUnits:
		gridManager.setPosition_occupied(unit.getGridPos())
	

func startLevel() -> void:
	nextTurn()


func printUnitTimes() -> String:
	var text: String = "\n"
	for unit in playerUnits:
		text += unit.getName() + " | " + str(unit.getTurnTimer()) + "\n"
	for unit in allyUnits:
		text += unit.getName() + " | " + str(unit.getTurnTimer()) + "\n"
	for unit in enemyUnits:
		text += unit.getName() + " | " + str(unit.getTurnTimer()) + "\n"

	return text

func stateChange(state:int) -> void:
	curState = state

#engine operation
func _ready():
	gridManager.init(mapSize,collisionWalls)
	aiManager.attackPlayer_input.connect(aiAttackTurn)
	aiManager.connect("stateChange",stateChange)
	aiManager.setRoot(self)

	itemAbMan.connect("actionComplete",itemEndTurn)
	
	updateOccupiedMapGrid()
	
func _physics_process(delta):
	if curState > STATE.GAME_OVER:
		unitOverlay()
		battleCam.input(!canCamMove(),!canCamRot())
	if curState > STATE.NONE:
		input()
		
