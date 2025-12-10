class_name BaseItem extends Node

@export var stringName: String
@export var range: int
@export var endTurn: bool
@export var apCost: int
@export var singlePart: bool
@export var tier: int = 1

@export_enum(
	"HP",
	"STATUS",
	"ATTACK"

) var itemType: int

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

func getType() -> int:
	return itemType

func getTier() -> int:
	return tier

#setters
func setName(newName:String) -> void:
	stringName = newName
