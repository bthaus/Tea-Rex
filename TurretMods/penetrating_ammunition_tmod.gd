extends TurretBaseMod
class_name PenetratingAmmunition

func _init():
	description="Projectiles penetrate enemies. "
	
func initialise(turret:TurretCore):
	turret.penetrations=3;
	super(turret)
	pass;
