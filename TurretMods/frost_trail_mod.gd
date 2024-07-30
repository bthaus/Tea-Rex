extends TurretBaseMod
class_name FrostTrailMod
var trails=[]
func on_shoot(projectile:Projectile):
	var frost = FrostTrail.get_trail()
	frost.initialise(self)
	frost.register_bullet(projectile)
	GameState.gameState.add_child(frost)
	trails.append(frost)
	super(projectile)
	pass;
func trigger_minion(monster):
	
	var frost=FrostDebuff.new(FROST_TRAIL_SLOW_DURATION*pow(FROST_TRAIL_SCALING,level),
	associate
	,level,
	FROST_TRAIL_SLOW_AMOUNT*pow(FROST_TRAIL_SCALING,level))
	frost.register(monster)
func trigger_projectile(p:Projectile):
	
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
