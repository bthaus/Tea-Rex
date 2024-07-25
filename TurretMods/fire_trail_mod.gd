extends TurretBaseMod
class_name FireTrailMod

func on_shoot(projectile:Projectile):
	var fire = FireTrail.get_trail()
	fire.initialise()
	fire.register_bullet(projectile)
	GameState.gameState.add_child(fire)
	super(projectile)
	pass;

