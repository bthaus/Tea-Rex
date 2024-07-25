extends TurretBaseMod
class_name FrostTrailMod

func on_shoot(projectile:Projectile):
	var frost = FrostTrail.get_trail()
	frost.initialise()
	frost.register_bullet(projectile)
	GameState.gameState.add_child(frost)
	super(projectile)
	pass;
