extends TurretCore
class_name GreenTurretCore

func setUpTower(holder):
	average_minions_hit=average_minions_hit+5
	super(holder)
	pass;
func showRangeOutline():
	for x in range(GameboardConstants.BOARD_HEIGHT):
		for y in range(GameboardConstants.BOARD_WIDTH):
			var pos = GameState.board.map_to_local(Vector2(x,y))
			GameState.gameState.gameBoard.show_outline(pos)
	pass ;

func on_hit(monster:Monster,damage,color:Turret.Hue,killed,projectile:Projectile):
	if killed: on_target_killed(monster)
	addDamage(damage)
	
	pass;
func on_projectile_removed(projectile:Projectile):
	for mod in turret_mods:
		mod.on_remove(projectile)
		mod.on_hit(projectile)
	pass;	
	
func getTarget():
	if minions.get_child_count() > 0:
		target = minions.get_children().pick_random()

	pass;

	
func checkTarget():
	return	
func setupCollision(clearing):
	return	
