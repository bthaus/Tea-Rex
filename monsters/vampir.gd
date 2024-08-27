extends MonsterCore
class_name Vampir

func on_spawn():
	death_animation_done.connect(func():
		var monster=Monster.create(Monster.MonsterName.BAT)
		holder.spawner.spawnEnemy(monster)
		monster.global_position=holder.path[clamp(holder.travel_index-1,0,holder.path.size())]
		monster.refresh_path()
		)
	pass;
