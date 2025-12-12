class_name BattleItem extends BaseItem

@export var oneUse: bool = true

@export_enum(
	"HP_SINGLE", 
) var id:int


#getters setters
func getID() -> int:
	return id

func isOneUse() -> bool:
	return oneUse
