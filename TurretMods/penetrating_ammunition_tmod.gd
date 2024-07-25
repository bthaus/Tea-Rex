extends TurretBaseMod
class_name PenetratingAmmunition
var penetration_amount=3

func _init():
	description="Projectiles penetrate enemies. "
	super(TurretBaseMod.ModType.PROJECTILE)
	
	pass;



func on_hit(p:Projectile):
	if p.penetrations>=0:
		p.duplicate_and_shoot(0,p)
	pass;
	
func initialise(turret:TurretCore):
	if turret is RedTurretCore:
		turret.num_active_projectiles+=penetration_amount
	turret.penetrations=penetration_amount;
	super(turret)
	associate.average_minions_hit=associate.average_minions_hit+penetration_amount
	pass;
