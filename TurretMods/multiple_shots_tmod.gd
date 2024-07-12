extends TurretBaseMod
class_name MultipleShotsMod

func _init():
	description="Shoot multiple, weaker Projectiles"
	super(TurretBaseMod.ModType.PROJECTILE)
	pass;

func initialise(turret:TurretCore):
	turret.damage=turret.damage/2
	super(turret)
	pass;

func on_shoot(projectile:Projectile):
	var degrees=[22.5,45,-22.5,-45]
	for degree in degrees:
		var p1=Projectile.factory.duplicate_bullet(projectile) as Projectile
		p1.global_position=projectile.global_position
		for mod in associate.turret_mods:
			mod.visual.prepare_projectile(p1)
		p1._toggle_emission(true)	
		p1.shoot(projectile.target)
		p1.direction=util.rotate_vector(projectile.direction,degree)
		p1.global_rotation = p1.direction.angle() + PI / 2.0
	
		pass;
	super(projectile)	
	pass;	
