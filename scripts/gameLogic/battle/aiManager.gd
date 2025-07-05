class_name AiManager extends Node

const BODYPARTS := preload("res://resources/scripts/enumClasses/ENUMbodyparts.gd").BODYPARTS

signal turnFinished










##
func getBestWeapon(unit: BaseUnit, enemyUnit: BaseUnit) -> int:
    var weapons: Array[Node] = unit.getWeapons()
    var chosenWeapon: int = -1
    
    for weapon in range(weapons.size()):
        if !weapons[weapon].getEquipPart().isDestroyed():
            if chosenWeapon == -1 || weapons[weapon].dmgCalc(weapons[weapon].isTwoHanded() && !weapons[weapon].getEquipPart().isDestroyed()) > weapons[chosenWeapon].dmgCalc(weapons[chosenWeapon].isTwoHanded() && !weapons[chosenWeapon].getEquipPart().isDestroyed()):
                chosenWeapon = weapon


    return chosenWeapon
    
