extends MonsterCore
class_name Necro
@export var summon:MonsterCore
func do_special():
	var monster=Monster.create(Monster.MonsterName.MINION)
	holder.spawner.spawnEnemy(monster)
	monster.global_position=holder.path[clamp(holder.travel_index-1,0,holder.path.size())]
	monster.refresh_path()
	pass;
