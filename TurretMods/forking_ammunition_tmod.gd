extends TurretBaseMod
class_name ForkingAmmunitionMod

func _init():
	description="Projectiles fork on impact."
	super(TurretBaseMod.ModType.PROJECTILE)
	pass;

func on_hit(projectile:Projectile):
	if projectile==null:return
	if projectile.penetrations<=-1 and projectile.penetrations>-500:
		return
	
	var p1=Projectile.factory.duplicate_bullet(projectile) as Projectile
	var p2=Projectile.factory.duplicate_bullet(projectile) as Projectile
	
	p1.global_position=projectile.global_position
	p2.global_position=projectile.global_position
	
	for mod in associate.turret_mods:
		mod.visual.prepare_projectile(p1)
		mod.visual.prepare_projectile(p2)
	
	p1.ignore_next_enemy=true;
	p2.ignore_next_enemy=true;
		
	p1.shoot(projectile.target)
	p1._toggle_emission(true)
	p2.shoot(projectile.target)
	p2._toggle_emission(true)
	
	p1.direction=util.rotate_vector(projectile.direction,45)
	p2.direction=util.rotate_vector(projectile.direction,-45)

	p1.global_rotation = p1.direction.angle() + PI / 2.0
	p2.global_rotation = p2.direction.angle() + PI / 2.0
	
	pass;
	
# Function to rotate a vector by 45 degrees. done by chatgpt
