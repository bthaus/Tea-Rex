extends TurretCore
class_name GreenTurretCore

func on_projectile_removed(projectile:Projectile):
	Explosion.create(Stats.TurretColor.GREEN, damage, projectile.global_position, self, Stats.green_explosion_range);
	super.on_projectile_removed(projectile)
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
