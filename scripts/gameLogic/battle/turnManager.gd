class_name TurnManager extends Node

@onready var unitGui : VBoxContainer= $Control/unitOrderGFX

const turnOrderCnt: int = 6
var turnCnt: int = -1
var unitOrder: Array[BaseUnit] #next 10 turns


#methods
func getTurnNo() -> int:
	return turnCnt

func nextTurn() -> void:
	turnCnt += 1



func calcTurnOrder(turn: int, unitArray: Array[Node]) -> Array[BaseUnit]:
	if turn == 0:
		unitOrder = []

		for unit in unitArray:
			unit.resetPredTurnTimer()

	unitOrder.append(orderTurn(unitArray, 0, unitArray.size() - 1)[unitArray.size() - 1])

	if unitOrder.size() == turnOrderCnt:
		updateUnitGuiOrder()
		return unitOrder
	
	unitArray[unitArray.size()-1].setPredTurnTimer(0)
	for unitIndex in range(unitArray.size() - 1):
		var  unit = unitArray[unitIndex]
		unit.setPredTurnTimer(unit.getPredTurnTimer() + unit.getStat("agility"))
		

	return calcTurnOrder(turn + 1, unitArray)
	


#turn ordering based on unit turn time
func orderTurnPartition(unitArray: Array[Node], lowIndex: int, highIndex: int) -> int:
	var pivotUnit: BaseUnit = unitArray[highIndex]
	var swapIndex = lowIndex -1

	for unitIndex in range(lowIndex, highIndex):
		if (unitArray[unitIndex].getPredTurnTimer() < pivotUnit.getPredTurnTimer()):
			swapIndex += 1
			
			var temp = unitArray[unitIndex]
			unitArray[unitIndex] = unitArray[swapIndex]
			unitArray[swapIndex] = temp
			
				
	var temp = pivotUnit
	unitArray[highIndex] = unitArray[swapIndex + 1]
	unitArray[swapIndex + 1] = temp

	return swapIndex + 1

func orderTurn(unitArray: Array[Node], lowIndex: int, highIndex: int) -> Array[Node]:
	if lowIndex < highIndex:
		var pivot: int = orderTurnPartition(unitArray,lowIndex,highIndex)

		orderTurn(unitArray,lowIndex,pivot - 1)
		orderTurn(unitArray,pivot + 1, highIndex)

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
