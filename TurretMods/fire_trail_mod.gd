extends TurretBaseMod
class_name FireTrailMod
var trails=[]
var strength_of_fire_dot=1
func on_shoot(projectile:Projectile):
	var trail = FireTrail.get_trail(associate)
	trail.initialise()
	trail.register_bullet(projectile)
	GameState.gameState.add_child(trail)
	super(projectile)
	trails.append(trail)
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
func on_level_up(lvl):
	strength_of_fire_dot=lvl
	super(lvl)
	pass;
