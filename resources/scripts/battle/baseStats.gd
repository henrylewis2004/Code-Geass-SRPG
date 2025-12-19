class_name Stats

var stats: Array[int] 
var status: Array[Array]
const STATS := preload("res://resources/scripts/enumClasses/ENUMstats.gd").UNIT_STATS
const maxStatusPower: int = 5

## methods
func getAbsStat(stat: int) -> int:
	return stats[stat]

func getStat(stat:int) -> int:
	return (stats[stat] + getStatStatusPower(stat) * 0.2 * stats[stat])

func getStatStatusList(stat:int) -> Array:
	return status[stat]

func getStatStatusPower(stat:int) -> int:
	var power: int = 0
	for affect in status[stat]:
		power += affect.getPower()

	return power if abs(power) <= getMaxStatusPower() else maxStatusPower * -1 if power < 0 else maxStatusPower * 1


func getMaxStatusPower() -> int:
	return maxStatusPower
	
#status
func addStatus(newStatus: Status) -> void:
	status[newStatus.getStat()].append(newStatus)

func cleanStatus() -> void:
	for s in status:
		s = []

#init
func _init(ag:int=0,de:int=0,ev:int=0,me:int=0,ra:int=0,newAp:int=0,newApCharge:int=0,en:int=0,enCharge:int=0,lu:int=0,ini:int=0) -> void:
	stats = []
	status = []
	for stat in STATS.size():
		stats.append(0)
		status.append([])



	stats[STATS.AGILITY] = ag
	stats[STATS.DEFENCE] = de
	stats[STATS.EVASION] = ev
	stats[STATS.MELEE] = me
	stats[STATS.RANGED] = ra
	stats[STATS.AP] = newAp
	stats[STATS.AP_CHARGE] = newApCharge
	stats[STATS.ENERGY] = en
	stats[STATS.ENERGY_CHARGE] = enCharge
	stats[STATS.LUCK] = lu
	stats[STATS.INITIATIVE] = ini
