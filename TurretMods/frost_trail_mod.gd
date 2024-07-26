extends TurretBaseMod
class_name FrostTrailMod
var trails=[]
func on_shoot(projectile:Projectile):
	var frost = FrostTrail.get_trail(associate)
	frost.initialise()
	frost.register_bullet(projectile)
	GameState.gameState.add_child(frost)
	trails.append(frost)
	super(projectile)
	pass;

func on_cell_traversal(projectile:Projectile):
	for trail in trails:
		trail.on_cell_traversal()
	super(projectile)	
	pass;
func remove():
	for trail in trails:
		trail.remove()
	super()
	pass;	
