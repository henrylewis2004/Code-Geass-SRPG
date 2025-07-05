class_name BodyPart extends Node

const BODYPARTS = preload("res://resources/scripts/enumClasses/ENUMbodyparts.gd").BODYPARTS

@export var totalHp: int
@export var string_name : String
@export var destroyed: bool = false
@export var bodyPartType: int

var hp: int

#getters
func getHp() -> int:
    return hp

func getName() -> String:
    return string_name

func getType() -> int:
    return bodyPartType

func isDestroyed() -> bool:
    if (hp <= 0):
        destroy()
    return destroyed

func getTotalHp() -> int:
    return totalHp

func getHpRatio() -> float:
    return float(hp)/float(totalHp) * 100 

#setters
func setHp(newHp: int, hpTotal: int) -> void:
    hp = newHp
    totalHp = hpTotal
    
func hit(dmg: int) -> void:
    hp -= dmg
    
func setName(newName: String) -> void:
    string_name = newName
    
    
func setDestroyed(isDestroyed: bool) -> void:
    destroyed = isDestroyed
    
func setBodypartType(type: int) -> void:
    bodyPartType = type
    
#methods
func destroy():
    destroyed = true
    hp = 0
    
#engine
func _ready():
    hp = totalHp