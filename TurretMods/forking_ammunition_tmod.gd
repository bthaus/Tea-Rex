extends TurretBaseMod
class_name ForkingAmmunitionMod
var degrees=[25,-25]
var degree_offset=FORKING_DEGREE

func initialise(turret:TurretCore):
	super(turret)
	associate.average_minions_hit=associate.average_minions_hit+2
	pass;
func on_hit(projectile:Projectile,monster:Monster):
	if projectile==null:return
	#if projectile.penetrations<=-1 and projectile.penetrations>-500:
		#return
	if projectile.is_duplicate:return
	for degree in degrees:
		var p=projectile.duplicate_and_shoot(degree)
		p.ignore_next_enemy=true
	
	pass;
func on_level_up(lvl):
	degrees.clear()
	var neg=1
	var degstack=degree_offset
	for i in range(lvl*2):
		neg*=-1
		var deg=degstack*neg
		if neg>0:
			degstack+=degree_offset
		degrees.append(deg)
	super(lvl)
	pass;	
	
# Function to rotate a vector by 45 degrees. done by chatgpt
