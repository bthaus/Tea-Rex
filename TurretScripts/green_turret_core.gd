extends TurretCore
class_name GreenTurretCore



func on_hit(monster:Monster,damage,color:Stats.TurretColor,killed):
	Explosion.create(color, damage, monster.global_position, self, Stats.green_explosion_range);
	super.on_hit(monster,damage,color,killed)
	pass;
# Called every frame. 'delta' is the elapsed time since the previous frame.
