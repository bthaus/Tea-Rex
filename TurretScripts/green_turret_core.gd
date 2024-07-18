extends TurretCore
class_name GreenTurretCore


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
func showRangeOutline():
	return	
	
func checkTarget():
	return	
func setupCollision(clearing):
	return	
