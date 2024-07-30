extends TurretBaseMod
class_name GhostProjectileMod


func on_shoot(p:Projectile):
	p.wall_penetrations=level
	p.ghost_projectile=true
	super(p)
	pass;
