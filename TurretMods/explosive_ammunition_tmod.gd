extends TurretBaseMod
class_name ExplosiveAmmunition

func _init():
	description="Projectiles explode on contact"
	super(TurretBaseMod.ModType.AMMUNITION)
	
	pass;
func initialise(turret:TurretCore):
	super(turret)
	associate.average_minions_hit=associate.average_minions_hit+5
	pass;
func on_hit(projectile:Projectile):
	Explosion.create(projectile.type,projectile.damage,projectile.get_global(),projectile.associate,0.5)
	super.on_hit(projectile)
	pass;
func on_remove(projectile:Projectile):
	on_hit(projectile)
	pass;	
