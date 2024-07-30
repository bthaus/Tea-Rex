extends TurretBaseMod
class_name VoodooKillMod

func on_kill(m:Monster):
	var triggering=randi_range(0,100)>VOODOO_KILL_CHANCE
	if not triggering:super(m); return
	var ms=GameState.monsters.get_children()
	while !ms.is_empty():
		var monster=ms.pick_random()as Monster
		if monster.monstertype==Monster.Monstertype.BOSS:
			ms.erase(monster)
			continue
		else:monster.hit(Turret.Hue.MAGENTA,9999999)
		break;
	super(m)		
	pass;
