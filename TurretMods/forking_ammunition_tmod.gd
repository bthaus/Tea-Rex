extends TurretBaseMod
class_name ForkingAmmunitionMod
var degrees=[45,-45]
func _init():
	description="Projectiles fork on impact."
	super(TurretBaseMod.ModType.PROJECTILE)
	
	pass;
func initialise(turret:TurretCore):
	if turret is RedTurretCore:
		turret.num_active_projectiles+=degrees.size()
	super(turret)
	associate.average_minions_hit=associate.average_minions_hit+2
	pass;
func on_hit(projectile:Projectile):
	if projectile==null:return
	if projectile.penetrations<=-1 and projectile.penetrations>-500:
		return
	
	for degree in degrees:
		var p=projectile.duplicate_and_shoot(degree)
		p.ignore_next_enemy=true
	
	pass;
	
# Function to rotate a vector by 45 degrees. done by chatgpt
