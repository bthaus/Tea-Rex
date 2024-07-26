extends GameObjectCounted
class_name TurretBaseMod
var description="I am a base mod. I dont do anything"
var visual:ModVisual
var associate:TurretCore
var type:ModType
var level=1
var damage_factor=1

static var color_blocks={
	TARGETING=[],
	HULL=[],
	PROJECTILE=[],
	AMMUNITION=[],
	PRODUCTION=[],
	ONKILL=[]
}
static var implemented_mods={
	TARGETING=[],
	HULL=[],
	PROJECTILE=[ForkingAmmunitionMod,MultipleShotsMod,PenetratingAmmunition],
	AMMUNITION=[ExplosiveAmmunition,],
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
	level=associate.stacks
	turret.add_child(visual)
	pass;

func on_level_up(lvl):
	level=lvl
	pass;
func get_damage():
	return (associate.damage*associate.damagefactor)*(damage_factor*level)
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
