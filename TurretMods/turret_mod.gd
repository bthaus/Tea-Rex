extends GameObjectCounted
class_name TurretBaseMod
var description="I am a base mod. I dont do anything"
var visual:ModVisual


func initialise(turret:TurretCore):
	visual=ModVisualFactory.get_visual(self)
	#visual.global_position=turret.global_position
	turret.add_child(visual)
	
	
	pass;

func on_shoot(projectile:Projectile):
	visual.on_shoot(projectile)
	pass;
func on_hit(projectile:Projectile):
	visual.on_hit(projectile)
	pass;
