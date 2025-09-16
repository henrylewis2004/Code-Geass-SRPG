class_name GridTile

var tileId : Vector2
var occupied: bool 

func _init(position: Vector2):
    tileId = position
    occupied = false
    
func isOccupied() -> bool:
    return occupied

func setOccupied(set: bool) -> void:
    occupied = set


