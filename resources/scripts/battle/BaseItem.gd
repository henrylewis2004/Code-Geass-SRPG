class_name BaseItem extends Node

@export var stringName: String
@export var range: int
@export var endTurn: bool
@export var apCost: int
@export var singlePart: bool

#getters setters
func getApCost() -> int:
	return apCost

func getName() -> String:
	return stringName

func getRange() -> int:
	return range

func getEndTurn() -> bool:
	return endTurn

func isSinglePart() -> bool:
	return singlePart