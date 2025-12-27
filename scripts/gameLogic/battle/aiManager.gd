class_name AiManager extends Node

const BODYPARTS := preload("res://resources/scripts/enumClasses/ENUMbodyparts.gd").BODYPARTS

signal turnFinished
signal actionTaken(taken:bool)

signal attackPlayer_input(unit: BaseUnit, targetUnit: BaseUnit)

var tree_root: Node



###
func setRoot(new_root:Node) -> void:
	tree_root = new_root



##
func getBestWeapon(unit: BaseUnit, enemyUnit: BaseUnit, grid: BattleGrid) -> int:
	var weapons: Array[Node] = unit.getWeapons()
	var chosenWeapon: int = -1
	
	for weapon in range(weapons.size()):
		if !weapons[weapon].getEquipPart().isDestroyed():
			if chosenWeapon == -1 || ( weapons[weapon].dmgCalc(weapons[weapon].isTwoHanded() && !weapons[weapon].getEquipPart().isDestroyed(),unit,enemyUnit) > weapons[chosenWeapon].dmgCalc(weapons[chosenWeapon].isTwoHanded() && !weapons[chosenWeapon].getEquipPart().isDestroyed(), unit,enemyUnit) ):
				if weapons[weapon].getRange() >= grid.absDist(unit.getGridPos(),enemyUnit.getGridPos()):
					chosenWeapon = weapon


	return chosenWeapon
	


func inRange(unit:BaseUnit,targetUnit:BaseUnit,itemRange:int,grid:BattleGrid,allyUnits: Array[Node]) -> bool:
	if grid.absDist(unit.getGridPos(),targetUnit.getGridPos()) <= itemRange:
		return true
	

	var asBoard: AStar2D = grid.getAstar()
	for index_x in itemRange:
		for index_y in itemRange:
			if index_x + index_y > itemRange:
				break

			if index_x != 0 && index_y != 0:
				if grid.isOccupiedPosition(unit.getGridPos()):
					pass
				elif grid.dist(unit.getGridPos(),targetUnit.getGridPos() + Vector2(index_x,index_y)) <= unit.getMoveRange():
					return true
				elif grid.dist(unit.getGridPos(),targetUnit.getGridPos() - Vector2(index_x,index_y)) <= unit.getMoveRange():
					return true
				elif grid.dist(unit.getGridPos(),targetUnit.getGridPos() + Vector2(-index_x,index_y)) <= unit.getMoveRange():
					return true
				elif grid.dist(unit.getGridPos(),targetUnit.getGridPos() + Vector2(index_x,-index_y)) <= unit.getMoveRange():
					return true
				


	return false

func getAttackRange(unit:BaseUnit) -> int:
	var wpnRange: int = 0
	for weapon in unit.getWeapons():
		if !weapon.getEquipPart().isDestroyed():
			var newWpnRange: int = int(weapon.getApCost() <= unit.getAp()) * ( weapon.getRange() + max(0,min(unit.getAp() - weapon.getApCost(),unit.getMoveRange())))

			if newWpnRange > wpnRange:
				wpnRange = newWpnRange
		

	return wpnRange



func bestAttack(mv:Vector2, weapon: Weapon, unit:BaseUnit, targetUnit:BaseUnit, grid:BattleGrid) -> int:
	if grid.absDist(unit.getGridPos() + mv,targetUnit.getGridPos()) <= weapon.getRange():
		if unit.hasLOS(targetUnit,Vector3(unit.getGridPos().x + mv.x,0,unit.getGridPos().y + mv.y)):
			if grid.isOccupiedPosition(unit.getGridPos() + mv):
				return -10000

			var newDmgCalc: int = weapon.dmgCalc(weapon.isTwoHanded(),unit,targetUnit)
			return newDmgCalc
		
	return -10000




	
func attackTurn(unit:BaseUnit, allyUnits: Array[BaseUnit],enemyUnits: Array[Node],attackRange: int,grid: BattleGrid,camera: BattleCamController) -> void:
	if attackRange == 0:
		actionComplete_timeout(false,0.01)
		return

	var targetEnemy: BaseUnit = null
	var dmgCalc: int = 0
	var targetMv: Vector2 = Vector2.ZERO

	for e_unit in enemyUnits:
		if grid.absDist(unit.getGridPos(),e_unit.getGridPos()) <= attackRange:
			for weapon in unit.getWeapons():
				var wpnRange: int = int(weapon.getApCost() <= unit.getAp()) * ( weapon.getRange() + max(0,min(unit.getAp() - weapon.getApCost(),unit.getMoveRange())))

				if wpnRange > 0:
					var mvRange: int = wpnRange - weapon.getRange()
					
					var newDmgCalc : int = bestAttack(Vector2.ZERO,weapon,unit,e_unit,grid)
					if newDmgCalc > dmgCalc:
						dmgCalc = newDmgCalc
						targetEnemy = e_unit
						targetMv = Vector2.ZERO
						unit.setEquippedWeapon_fromWeapon(weapon)
					
					for index_x in mvRange:
						for index_y in mvRange:
							if index_x + index_y == 0 :
								pass
							
							elif index_x + index_y < mvRange:
								newDmgCalc = bestAttack(Vector2(index_x,index_y),weapon,unit,e_unit,grid)
								if newDmgCalc > dmgCalc:
									dmgCalc = newDmgCalc
									targetEnemy = e_unit
									targetMv = Vector2(index_x,index_y)
									unit.setEquippedWeapon_fromWeapon(weapon)

								newDmgCalc = bestAttack(Vector2(-index_x,-index_y),weapon,unit,e_unit,grid)
								if newDmgCalc > dmgCalc:
									dmgCalc = newDmgCalc
									targetEnemy = e_unit
									targetMv = Vector2(-index_x,-index_y)
									unit.setEquippedWeapon_fromWeapon(weapon)

								newDmgCalc = bestAttack(Vector2(index_x,-index_y),weapon,unit,e_unit,grid)
								if newDmgCalc > dmgCalc:
									dmgCalc = newDmgCalc
									targetEnemy = e_unit
									targetMv = Vector2(index_x,-index_y)
									unit.setEquippedWeapon_fromWeapon(weapon)

								newDmgCalc = bestAttack(Vector2(-index_x,index_y),weapon,unit,e_unit,grid)
								if newDmgCalc > dmgCalc:
									dmgCalc = newDmgCalc
									targetEnemy = e_unit
									targetMv = Vector2(-index_x,index_y)
									unit.setEquippedWeapon_fromWeapon(weapon)
				

	if targetEnemy == null:
		actionComplete_timeout(false,0.01)
		return
	
	if targetMv != Vector2.ZERO:
		var moveCost: int = unit.moveCost(grid.getASindex(unit.getGridPos()),grid.getASindex(unit.getGridPos() + targetMv),grid.getAstar())
		unit.incAp(-moveCost)

		grid.setPosition_occupied(unit.getGridPos() + targetMv,unit.getGridPos())
		unit.moveTo(grid.getASindex(unit.getGridPos()),grid.getASindex(unit.getGridPos() + targetMv),grid.getAstar())

		camera.followUnit(unit)
		await unit.movementFinished
		camera.clearUnitFollow()

	#get user input
	attackPlayer_input.emit(unit,targetEnemy)
	
	
func actionComplete_timeout(actionComplete: bool = true,timeout: float = 0) -> void:
	if timeout > 0:
		var timer: Timer = Timer.new()
		timer.one_shot = true

		tree_root.add_child(timer)
		timer.start(timeout)

		await timer.timeout

		tree_root.remove_child(timer)
		timer.queue_free()

	actionTaken.emit(actionComplete)


			
func moveTurn(unit: BaseUnit, enemyUnits: Array[Node],grid:BattleGrid,camera:BattleCamController) -> void:
	var closestEnemy: BaseUnit = null
	var dist: int = 0
	for e_unit in enemyUnits:
			if closestEnemy == null || grid.absDist(unit.getGridPos(),e_unit.getGridPos()) < grid.absDist(unit.getGridPos(),closestEnemy.getGridPos()):
				closestEnemy = e_unit
				

	if closestEnemy == null || grid.absDist(closestEnemy.getGridPos(),unit.getGridPos()) < unit.getEquippedWeapon().getRange():
		actionComplete_timeout(false,0.01)
		return
	
	var targetLoc: Vector2 = findMovementTile(closestEnemy,unit,grid)

	if targetLoc != Vector2.INF :
		var moveCost: int = unit.moveCost(grid.getASindex(unit.getGridPos()),grid.getASindex(targetLoc),grid.getAstar())
		print(unit.getAp())
		unit.incAp(-moveCost)
		print(unit.getAp())

		grid.setPosition_occupied(targetLoc,unit.getGridPos())
		unit.moveTo(grid.getASindex(unit.getGridPos()),grid.getASindex(targetLoc),grid.getAstar())

		camera.followUnit(unit)
		await unit.movementFinished
		camera.clearUnitFollow()
		
		actionComplete_timeout(true,0.01)
		return
	
	actionComplete_timeout(false,0.01)


	
	
	
	
func findMovementTile(targetEnemy: BaseUnit,unit: BaseUnit,grid:BattleGrid) -> Vector2:
	for indexX in int(grid.getMapSize().x - 1):
		for indexY in int(grid.getMapSize().y - 1):
			if indexX + indexY == 0:
				pass
			
			else:
				var tile_adjust: Vector2 = validMovementTile(unit.getGridPos(),targetEnemy.getGridPos(),Vector2(indexX,indexY),grid)

				if tile_adjust != Vector2.INF && !grid.isOccupiedPosition(targetEnemy.getGridPos() + Vector2(indexX,indexY) * tile_adjust):
					var movePath: PackedVector2Array = grid.getPath(unit.getGridPos(),targetEnemy.getGridPos() + Vector2(indexX,indexY) * tile_adjust)

					var targetLoc: Vector2 = movePath[min(unit.getMoveRange(),movePath.size() - 1)]
					
					if !grid.isOccupiedPosition(targetLoc):
						return targetLoc
					
					

			
	return Vector2.INF


func validMovementTile(unitOrigin:Vector2,enemyPos:Vector2,posDif: Vector2,grid:BattleGrid) -> Vector2:
	if grid.dist(enemyPos + posDif, unitOrigin) > 0 && enemyPos.x + posDif.x < grid.getMapSize().x && enemyPos.y + posDif.y < grid.getMapSize().y:
		return Vector2(1,1)
	elif grid.dist(enemyPos - posDif, unitOrigin) > 0 && enemyPos.x - posDif.x >= 0 && enemyPos.y - posDif.y >= 0:
		return Vector2(-1,-1)
	elif grid.dist(enemyPos + Vector2(-posDif.x,posDif.y), unitOrigin) > 0 && enemyPos.y + posDif.y < grid.getMapSize().x && enemyPos.x + posDif.x >= 0:
		return Vector2(-1,1)
	elif grid.dist(enemyPos + Vector2(posDif.x,-posDif.y), unitOrigin) > 0 && enemyPos.x + posDif.x < grid.getMapSize().x && enemyPos.y + posDif.y >= 0:
		return Vector2(1,-1)

	return Vector2.INF




func getTurn(unit: BaseUnit, allyUnits: Array[Node],enemyUnits: Array[Node],grid: BattleGrid, camera: BattleCamController, itemAbManager: Item_abilityManager) -> void:
	var asBoard = grid.getAstar()
	var teamUnits: Array[BaseUnit] = []

	for a_unit in allyUnits:
		if a_unit != unit:
			teamUnits.append(a_unit)
	
	if unit.getBodyparts().size() > 1 && (unit.getBodyparts()[BODYPARTS.L_ARM].isDestroyed() && unit.getBodyparts()[BODYPARTS.R_ARM].isDestroyed()):
		#do nothing
		endTurn()
		return
	


	#attack
	attackTurn(unit,teamUnits,enemyUnits,getAttackRange(unit),grid,camera)
	if await actionTaken:
		endTurn()
		return


	#move
	moveTurn(unit,enemyUnits,grid,camera)
	if await actionTaken:
		endTurn()
		return
	
	endTurn()



func endTurn() -> void:
	turnFinished.emit()
	
