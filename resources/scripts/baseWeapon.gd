class_name Weapon extends Node

@export var dmg: int
@export var string_name: String
@export var accuracy: int
@export var rounds: int
@export var twoHanded: bool
@export var apCost: int
@export var equipPart: BodyPart
@export var range: int

#getters
func getDmg() -> int:
    return dmg

func getName() -> String:
    return string_name

func getAccuracy() -> int:
    return accuracy

func getRounds() -> int:
    return rounds

func getRange() -> int:
    return range

func getWpnInfo() -> Array:
    return [dmg,string_name,accuracy,rounds, range]


#methods
func hit() -> bool: #need to add two handed debuff
    var hitInt: int = randi() % 101
    if (hitInt < accuracy):
        return true
    return false

func dmgCalc() -> int:
    var totalDmg: int = 0
    
    for bullet in rounds:
        if hit():
            totalDmg += dmg

    return totalDmg


    