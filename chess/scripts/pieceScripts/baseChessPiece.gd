class_name chess_basePiece

var type: int 
@export var name: String
@export_enum("player", "opponent") var team: int

var canPromote: bool = false
var validMoves: Array[Vector2]

#getters 
func getType() -> int:
	return type

func getName() -> String:
	return name

func getTeam() -> int:
	return team

#setters
func setType(newtype: int) -> void:
	type = newtype

func setName(newName: String) -> void:
	name = newName

func setTeam(newTeam:int ) -> void:
	team = newTeam


#methods

