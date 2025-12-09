class_name Stats

var stats: Array[int] = [0,0,0,0,0,0,0,0,0]
const STATS := preload("res://resources/scripts/enumClasses/ENUMstats.gd").UNIT_STATS

func getStat(stat: int) -> int:
	return stats[stat]

func _init(ag:int,de:int,ev:int,me:int,ra:int,newAp:int,en:int,lu:int,ini:int) -> void:
	stats[STATS.AGILITY] = ag
	stats[STATS.DEFENCE] = de
	stats[STATS.EVASION] = ev
	stats[STATS.MELEE] = me
	stats[STATS.RANGED] = ra
	stats[STATS.AP] = newAp
	stats[STATS.ENERGY] = en
	stats[STATS.LUCK] = lu
	stats[STATS.INITIATIVE] = ini

