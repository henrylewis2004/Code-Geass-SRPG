class_name ChessBoard_Manager extends Node2D

const PIECES := preload("res://chess/resources/enumClasses/ENUMchess.gd").CHESS_PIECES
const COL := preload("res://chess/resources/enumClasses/ENUMchess.gd").TEAMCOLOURS
const STATES := preload("res://chess/resources/enumClasses/ENUMchess.gd").STATES


@export var playerTurn: bool = true #is white turn or note, black turn for false
@export_enum("white","black") var playerTeam: int

var player: PlayerController = PlayerController.new(playerTeam)
var curState: int = STATES.NONE

@onready var board: ChessGameBoard = ChessGameBoard.new($pieces.get_children())
@onready var drawMan: ChessDrawManager = $drawman

var selectedUnit: chess_basePiece

func turn() -> void:
	playerTurn = false if playerTurn == true else true
	if playerTurn:
		curState = STATES.MOVEMENT

func input() -> void:
	match curState:
		STATES.MOVEMENT:
			if (Input.is_action_just_pressed("left") || Input.is_action_just_pressed("right") || Input.is_action_just_pressed("up")|| Input.is_action_just_pressed("down")):
				var input: Vector2 = Vector2(int(Input.is_action_just_pressed("right")) - int(Input.is_action_just_pressed("left")),int(Input.is_action_just_pressed("down")) - int(Input.is_action_just_pressed("up") ))
				player.movement(input)
				drawMan.updatePlayerPos(player.getGridPos(), board.getCellSize(),board.getStartLoc())

			elif (Input.is_action_just_pressed("accept")):
				var piece := board.getUnitAt(player.getGridPos())

				if piece:
					drawMan.clearPlayerRect()
					if piece.getColour() == playerTeam:
						selectUnit(piece)
					else:
						print(piece.getColour())



func selectUnit(piece: chess_basePiece) -> void:
	selectedUnit = piece
	board.getMoveTiles(piece)


#engine runtime
func _ready():
	curState = STATES.MOVEMENT

func _process(delta) -> void:
	input()
