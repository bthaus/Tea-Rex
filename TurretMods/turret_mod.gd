extends GameObjectCounted
class_name TurretBaseMod
var description="I am a base mod. I dont do anything"
var visual:ModVisual
var associate:TurretCore
var type:ModType
var shape:Block.BlockShape
var color:Turret.Hue
var level=1
var damage_factor=1
#constants
const FROST_TRAIL_SLOW_AMOUNT = 100
const FROST_TRAIL_SLOW_DURATION = GameplayConstants.DEBUFF_STANDART_LIFETIME

const FIRE_TRAIL_TICK_DAMAGE=1
const FIRE_TRAIL_FIRE_DURATION = GameplayConstants.DEBUFF_STANDART_LIFETIME


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
	PROJECTILE=[MultipleShotsMod,PenetratingAmmunition,FireTrailMod,FrostTrailMod],
	AMMUNITION=[ExplosiveAmmunition,ForkingAmmunitionMod,],
	PRODUCTION=[],
	ONKILL=[]
	
}

enum ModType{BASE=Turret.Hue.WHITE,
HULL=Turret.Hue.BLUE,
PROJECTILE=Turret.Hue.YELLOW,
AMMUNITION=Turret.Hue.RED,
PRODUCTION=Turret.Hue.GREEN,
ONKILL=Turret.Hue.MAGENTA}

func _init():
	var data=GameplayConstants.get_mod_data(self)
	type=data.type
	shape=data.shape
	color=ModType.values()[type]+1
	pass;

func initialise(turret:TurretCore):
	visual=ModVisualFactory.get_visual(self)
	associate=turret
	level=associate.stacks
	turret.add_child(visual)
	pass;
func get_item():
	var item=ItemBlockDTO.new(color,shape)
	item.turret_mod=self
	return item
	
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
func on_hit(projectile:Projectile,monster:Monster):
	visual.on_hit(projectile)
	pass;
func on_remove(projectile:Projectile):
	visual.on_remove(projectile)
	pass;
func remove():
	visual.queue_free()
	pass;
