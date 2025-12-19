class_name TurnManager extends Node

@onready var unitGui : VBoxContainer= $Control/unitOrderGFX

const turnOrderCnt: int = 6 #the number of units to display
var turnCnt: int = -1
var unitOrder: Array[BaseUnit] #next 10 turns

const STATS := preload("res://resources/scripts/enumClasses/ENUMstats.gd").UNIT_STATS


#methods
func getTurnNo() -> int:
	return turnCnt

func nextTurn() -> void:
	turnCnt += 1


func createTurnOrder(unitArray: Array[Node]) -> void:
	nextTurn()
	unitOrder = []

	for unit in unitArray:
		unit.resetPredTurnTimer()

	if getTurnNo() == 0:
		calcFirstTurnOrder(unitArray)
		updateUnitGuiOrder()
		return

	if getTurnNo() > 0:
		for unit in unitArray:
			unit.incTurnTimer()


	calcTurnOrder(unitArray)
	updateUnitGuiOrder()

		


func calcFirstTurnOrder(unitArray: Array[Node]) -> void:
	var order: Array[Node] = orderTurn(unitArray,0,unitArray.size() - 1)
	for unit in range(unitArray.size() - 1, -1, -1):
		print(unit)
		unitOrder.append(order[unit])

	calcTurnOrder(unitArray, 1)




func calcTurnOrder(unitArray: Array[Node],turn: int = 0) -> Array[BaseUnit]:

	var order : Array[Node] = orderTurn(unitArray, 0, unitArray.size() - 1)
	unitOrder.append(order[unitArray.size() - 1])


	if unitOrder.size() == turnOrderCnt:
		updateUnitGuiOrder()
		return unitOrder
	
	unitArray[unitArray.size()-1].setPredTurnTimer(0)
	for unit in unitArray:
		unit.setPredTurnTimer(unit.getPredTurnTimer() + unit.getStat(STATS.AGILITY))
		

	return calcTurnOrder(unitArray,turn + 1)
	


#turn ordering based on unit turn time
func orderTurnPartition(unitArray: Array[Node], lowIndex: int, highIndex: int) -> int:
	var pivotUnit: BaseUnit = unitArray[highIndex]
	var swapIndex = lowIndex -1

	for unitIndex in range(lowIndex, highIndex):
		if (unitArray[unitIndex].getPredTurnTimer() < pivotUnit.getPredTurnTimer()) || (unitArray[unitIndex].getPredTurnTimer() == pivotUnit.getPredTurnTimer() && unitArray[unitIndex].getStat(STATS.INITIATIVE) < pivotUnit.getStat(STATS.INITIATIVE)):
			swapIndex += 1
			
			var temp = unitArray[unitIndex]
			unitArray[unitIndex] = unitArray[swapIndex]
			unitArray[swapIndex] = temp
			
				
	var temp = pivotUnit
	unitArray[highIndex] = unitArray[swapIndex + 1]
	unitArray[swapIndex + 1] = temp

	return swapIndex + 1


#iniative
func orderTurnPartitionInitiative(unitArray: Array[Node], lowIndex: int, highIndex: int) -> int:
	var pivotUnit: BaseUnit = unitArray[highIndex]
	var swapIndex = lowIndex -1

	for unitIndex in range(lowIndex, highIndex):
		if (unitArray[unitIndex].getStat(STATS.INITIATIVE) < pivotUnit.getStat(STATS.INITIATIVE) || (unitArray[unitIndex].getStat(STATS.INITIATIVE) == pivotUnit.getStat(STATS.INITIATIVE) && unitArray[unitIndex].getStat(STATS.AGILITY) < pivotUnit.getStat(STATS.AGILITY))):
			swapIndex += 1
			
			var temp = unitArray[unitIndex]
			unitArray[unitIndex] = unitArray[swapIndex]
			unitArray[swapIndex] = temp
			
				
	var temp = pivotUnit
	unitArray[highIndex] = unitArray[swapIndex + 1]
	unitArray[swapIndex + 1] = temp

	return swapIndex + 1

##order the turn
func orderTurn(unitArray: Array[Node], lowIndex: int, highIndex: int, iniative: bool = false):
	if lowIndex < highIndex:
		var pivot: int 
		if iniative:
			pivot = orderTurnPartitionInitiative(unitArray,lowIndex,highIndex)

		else:
			pivot = orderTurnPartition(unitArray,lowIndex,highIndex)

		orderTurn(unitArray,lowIndex,pivot - 1,iniative)
		orderTurn(unitArray,pivot + 1, highIndex,iniative)
		

	return unitArray


#get next unit turn
func getNextUnit() -> BaseUnit:
	return unitOrder[0]


#unit turn showcase
func createUnitGuiOrder() -> void:
	for unitScreen in range(turnOrderCnt):
		var unit: TextureRect = TextureRect.new()
		unitGui.add_child(unit)
		
		unitGui.scale = Vector2(0.2,0.2)
		
func enlargeUnitGui() -> void:
	unitGui.scale = Vector2(0.5,0.5)
	
func resetUnitGuiScale() -> void:
	unitGui.scale = Vector2(0.2,0.2)
	

func updateUnitGuiOrder() -> void:
	var unitGuiArray := unitGui.get_children()
	for unit in range(unitOrder.size()):
		unitGuiArray[unit].texture = unitOrder[unit].getCharImage()


func _ready():
	createUnitGuiOrder()
