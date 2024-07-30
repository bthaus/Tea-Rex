extends TurretBaseMod
class_name ExplosiveUnitMod

func on_kill(monster:Monster):
	var hp=monster.maxHp
	hp=hp*EXPLOSIVE_UNIT_HEALTH_PERCENTAGE_DAMAGE*pow(EXPLOSIVE_UNIT_SCALING,level)
	Explosion.create(Turret.Hue.MAGENTA,hp,monster.get_global(),associate,EXPLOSIVE_UNIT_EXPLOSION_RANGE)
		
	pass;
