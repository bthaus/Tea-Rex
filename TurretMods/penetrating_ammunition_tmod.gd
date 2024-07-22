extends TurretBaseMod
class_name PenetratingAmmunition


func _init():
	description="Projectiles penetrate enemies. "
	super(TurretBaseMod.ModType.PROJECTILE)
	
	pass;



func on_hit(p:Projectile):
	if p.penetrations>=0:
		p.duplicate_and_shoot(0,p)
	pass;
	
func initialise(turret:TurretCore):
	turret.penetrations=3;
	super(turret)
	associate.average_minions_hit=associate.average_minions_hit+3
	pass;
