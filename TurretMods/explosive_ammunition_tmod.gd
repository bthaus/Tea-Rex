extends TurretBaseMod
class_name ExplosiveAmmunition

func _init():
	description="Projectiles explode on contact"
	super(TurretBaseMod.ModType.AMMUNITION)
	pass;

func on_hit(projectile:Projectile):
	Explosion.create(projectile.type,projectile.damage,projectile.global_position,projectile.associate,0.5)
	super.on_hit(projectile)
	pass;
func on_remove(projectile:Projectile):
	on_hit(projectile)
	pass;	
