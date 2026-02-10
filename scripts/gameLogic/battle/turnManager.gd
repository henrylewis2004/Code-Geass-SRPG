class_name TurnManager extends Node

@onready var unitGui : VBoxContainer= $Control/unitOrderGFX

class turnObject:
	var unit: BaseUnit
	var turnTime: int
	var agility: int
	var iniative: int

	func _init(unit: BaseUnit, turnTime:int, agility:int, iniative: int) -> void:
		self.unit = unit
		self.turnTime = turnTime
		self.agility = agility
		self.iniative = iniative

	func incTurnTime(inc: int = agility, turnCnt: int = 1) -> void:
		turnTime += inc * turnCnt

	func resetTurnTime() -> void:
		turnTime = 0

	func getUnit() -> BaseUnit:
		return unit

class turnAction:
	var movement: int = 0
	var attack: int= 0
	var item: int= 0

	const MOVECOST: int = 2

	func getTurnCost() -> int:
		return (movement + attack + item)

	func reset() -> void:
		movement = 0
		attack = 0
		item = 0

const turnOrderCnt: int = 6 #the number of units to display
var curTurn: int = 0
var unitOrder: Array[turnObject] #next 10 turns

const STATS := preload("res://resources/scripts/enumClasses/ENUMstats.gd").UNIT_STATS

var turnAction = turnAction.new()


#methods
func setTurnCost(field: String, val: int) -> void:
	match(field):
		"movement" -> turnAction.movement = val
		"attack" -> turnAction.attack = val
		"item" -> turnAction.item = val

func getTurnCost() -> int:
	return turnAction.getTurnCost()

func unitMoved(tiles: int ) -> void:
	self.setTurnCost("movement", tiles * turnAction.MOVECOST)




func resetTurnCost() -> void:
	turnAction.reset()


func printOrder() -> void:
	print("======unit order========")
	for unit in unitOrder:
		print(unit.getUnit().getName() + " | curTurnTime" + str(unit.getUnit().getTurnTimer()) + " | object turn time " + str(unit.turnTime) + " | iniatiative " + str(unit.iniative))


func getTurnNo() -> int:
	return curTurn


func createTurnOrder(unitArray: Array[BaseUnit]) -> void:
	unitOrder = []
	var turnUnits: Array[turnObject] = []
	var turnUnits_iniative: Array[turnObject] = []

	for unit in unitArray:
		var turnObj: turnObject = turnObject.new(unit,unit.getTurnTimer(),unit.getStat(STATS.AGILITY),unit.getStat(STATS.INITIATIVE))
		turnUnits.append(turnObj)

		if unit.hasMoved() == false:
			turnUnits_iniative.append(turnObject.new(unit,unit.getTurnTimer(),unit.getStat(STATS.AGILITY),unit.getStat(STATS.INITIATIVE)))


	if turnUnits_iniative.size() > 0:
		var order: Array[turnObject] = calcFirstTurnOrder(turnUnits_iniative)
		for unit in range(order.size() - 1, -1, -1):
			unitOrder.append(order[unit])

	calcTurnOrder(turnUnits)

	curTurn += 1
	for unit in unitArray:
		unit.incTurnTimer()

		


func calcFirstTurnOrder(unitArray: Array[turnObject]) -> Array[turnObject]:
	return orderTurn(unitArray,0,unitArray.size() - 1, true)

func calcTurnOrder(unitArray: Array[turnObject],turn: int = 0) -> Array[turnObject]:
	if unitOrder.size() == turnOrderCnt:
		updateUnitGuiOrder()
		return unitOrder

	var order : Array[turnObject] = orderTurn(unitArray, 0, unitArray.size() - 1)
	unitOrder.append(order[unitArray.size() - 1])
	
	for unit in unitArray:
		unit.incTurnTime()
	unitArray[unitArray.size()-1].resetTurnTime()
		

	return calcTurnOrder(unitArray,turn + 1)
	


#turn ordering based on unit turn time
func orderTurnPartition(unitArray: Array[turnObject], lowIndex: int, highIndex: int) -> int:
	var pivotUnit: turnObject = unitArray[highIndex]
	var swapIndex = lowIndex -1

	for unitIndex in range(lowIndex, highIndex):
		if (unitArray[unitIndex].turnTime < pivotUnit.turnTime) || (unitArray[unitIndex].turnTime == pivotUnit.turnTime && unitArray[unitIndex].iniative < pivotUnit.iniative):
			swapIndex += 1
			
			var temp: turnObject = unitArray[unitIndex]
			unitArray[unitIndex] = unitArray[swapIndex]
			unitArray[swapIndex] = temp
			
				
	var temp = pivotUnit
	unitArray[highIndex] = unitArray[swapIndex + 1]
	unitArray[swapIndex + 1] = temp

	return swapIndex + 1


#iniative
func orderTurnPartitionInitiative(unitArray: Array[turnObject], lowIndex: int, highIndex: int) -> int:
	var pivotUnit: turnObject = unitArray[highIndex]
	var swapIndex = lowIndex -1

	for unitIndex in range(lowIndex, highIndex):
		if (unitArray[unitIndex].iniative < pivotUnit.iniative || (unitArray[unitIndex].iniative == pivotUnit.iniative && unitArray[unitIndex].iniative < pivotUnit.iniative)):
			swapIndex += 1
			
			var temp : turnObject = unitArray[unitIndex]
			unitArray[unitIndex] = unitArray[swapIndex]
			unitArray[swapIndex] = temp
			
				
	var temp = pivotUnit
	unitArray[highIndex] = unitArray[swapIndex + 1]
	unitArray[swapIndex + 1] = temp

	return swapIndex + 1

##order the turn
func orderTurn(unitArray: Array[turnObject], lowIndex: int, highIndex: int, iniative: bool = false) -> Array[turnObject]:
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
	return unitOrder[0].getUnit()


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
		unitGuiArray[unit].texture = unitOrder[unit].getUnit().getCharImage()


func _ready():
	createUnitGuiOrder()
