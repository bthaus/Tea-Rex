extends TurretBaseMod
class_name PenetratingAmmunition


func _init():
	description="Projectiles penetrate enemies. "
	super(TurretBaseMod.ModType.PROJECTILE)
	pass;

	
func initialise(turret:TurretCore):
	turret.penetrations=3;
	super(turret)
	pass;
