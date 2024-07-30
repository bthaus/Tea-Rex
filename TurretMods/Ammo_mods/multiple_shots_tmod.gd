extends TurretBaseMod
class_name MultipleShotsMod
var degrees=[22.5,-22.5]
var degree_offset=22.5

func initialise(turret:TurretCore):
	if turret is RedTurretCore:
		turret.num_active_projectiles+=degrees.size()
	
	super(turret)
	associate.average_minions_hit=associate.average_minions_hit+4
	pass;

func on_shoot(projectile:Projectile):
	#var degrees=[22.5,45,-22.5,-45]
	if associate is RedTurretCore:return
	for degree in degrees:
		var p=projectile.duplicate_and_shoot(degree,associate)
		p.damage/=2
		#var p1=Projectile.factory.duplicate_bullet(projectile) as Projectile
		#p1.global_position=projectile.global_position
		#for mod in associate.turret_mods:
			#mod.visual.prepare_projectile(p1)
		#p1._toggle_emission(true)	
		#p1.shoot(projectile.target)
		#p1.direction=util.rotate_vector(projectile.direction,degree)
		#p1.global_rotation = p1.direction.angle() + PI / 2.0
	#
		pass;
	super(projectile)	
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
