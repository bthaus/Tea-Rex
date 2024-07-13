extends GameObjectCounted
class_name TurretBaseMod
var description="I am a base mod. I dont do anything"
var visual:ModVisual
var associate:TurretCore
var type:ModType


static var color_blocks={
	TARGETING=[],
	HULL=[],
	PROJECTILE=[Stats.TurretColor.RED,Stats.TurretColor.GREEN,Stats.TurretColor.MAGENTA],
	AMMUNITION=[],
	PRODUCTION=[],
	ONKILL=[]
}

enum ModType{TARGETING,HULL,PROJECTILE,AMMUNITION,PRODUCTION,ONKILL}

func _init(type:ModType=ModType.HULL):
	self.type=type
	pass;

func initialise(turret:TurretCore):
	visual=ModVisualFactory.get_visual(self)
	associate=turret
	turret.add_child(visual)
	
	
	
	pass;
func on_cell_traversal(projectile:Projectile):
	
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
func remove():
	visual.queue_free()
	pass;
