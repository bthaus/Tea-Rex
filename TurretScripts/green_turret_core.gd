extends TurretCore
class_name GreenTurretCore

func on_projectile_removed(pos):
	Explosion.create(Stats.TurretColor.GREEN, damage, pos, self, Stats.green_explosion_range);
	super.on_projectile_removed(pos)
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
