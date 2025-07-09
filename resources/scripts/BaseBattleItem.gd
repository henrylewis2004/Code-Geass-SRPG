class_name BattleItem extends BaseItem

@export_enum(
	"HP_30_SINGLE", "HP_50_SINGLE",
) var id:int


#getters setters
func getID() -> int:
	return id
