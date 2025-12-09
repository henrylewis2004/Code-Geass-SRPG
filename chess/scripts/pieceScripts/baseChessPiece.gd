class_name chess_basePiece extends Node

var type: int 
var typeString: String
var pieceName: String
@export_enum("white", "black") var colour: int

var canPromote: bool = false
var canMoveBack: bool = true
var canMoveToEdge: bool = true
var jumpPieces: bool = false

var gridPos: Vector2

#getters 
func getType() -> int:
	return type

func getTypeName() -> String:
	return typeString

func getPieceName() -> String:
	return pieceName

func getColour() -> int:
	return colour

func promotable() -> bool:
	return canPromote

func getGridPos() -> Vector2:
	return gridPos

func getSprite() -> Sprite2D:
	return $Sprite2D

#movement
func moveToEdge() -> bool:
	return canMoveToEdge

func jumpable() -> bool:
	return jumpPieces

func moveBackwards() -> bool:
	return canMoveBack


func getMovePattern() -> Array[Vector2]:
	return [Vector2(0,0)]

func getAttackPattern() -> Array[Vector2]:
	return getMovePattern()

#setters
func setType(newtype: int,newTypeString: String) -> void:
	type = newtype
	typeString = newTypeString

func setName(position: String) -> void:
	pieceName = typeString[0] 

	if typeString == "knight":
		pieceName += typeString[1] 

	pieceName += position

func setColourTeam(newColour:int ) -> void:
	colour = newColour
func setGridPos(pos: Vector2) -> void:
	gridPos = pos

#methods
func _ready():
	#set sprite image
	$Sprite2D.texture = load("res://chess/assets/chesspieces/color/" + ("white" if getColour() == 0 else "black") + "/"+ getTypeName() + ".png")

