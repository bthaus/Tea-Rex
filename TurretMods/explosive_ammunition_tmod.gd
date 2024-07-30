extends TurretBaseMod
class_name ExplosiveAmmunition


func initialise(turret:TurretCore):
	super(turret)
	associate.average_minions_hit=associate.average_minions_hit+5
	pass;
func on_hit(projectile:Projectile,monster:Monster):
	Explosion.create(projectile.type,get_damage(),projectile.get_global(),projectile.associate,0.5)
	super.on_hit(projectile,monster)
	pass;
func on_remove(projectile:Projectile):
	on_hit(projectile,null)
	pass;	
