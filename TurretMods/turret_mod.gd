extends GameObjectCounted
class_name TurretBaseMod
var description="I am a base mod. I dont do anything"
var visual:ModVisual
var associate:TurretCore


func initialise(turret:TurretCore):
	visual=ModVisualFactory.get_visual(self)
	associate=turret
	turret.add_child(visual)
	
	
	pass;
func on_cell_traversal(projectile:Projectile):
	print("traversed cell!!")
	pass;
	
func on_kill(monster:Monster):
	
	pass;
func on_shoot(projectile:Projectile):
	visual.on_shoot(projectile)
	pass;
func on_hit(projectile:Projectile):
	visual.on_hit(projectile)
	pass;
func on_remove(projectile:Projectile):
	visual.on_remove(projectile)
	pass;
