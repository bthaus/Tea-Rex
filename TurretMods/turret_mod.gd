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
var scale=1:
	get:
		var on=scale-1
		on*level
		return on+1
#constants
const FROST_TRAIL_SLOW_AMOUNT = 50
const FROST_TRAIL_SLOW_DURATION = GameplayConstants.DEBUFF_STANDART_LIFETIME
const FROST_TRAIL_SCALING=1.2

const FROST_AMMO_SLOW_AMOUNT = 100
const FROST_AMMO_SLOW_DURATION = GameplayConstants.DEBUFF_STANDART_LIFETIME
const FROST_AMMO_SCALING=1.5

const FROZEN_DURATION=1
const FROZEN_SCALING=1.2

const FIRE_TRAIL_TICK_DAMAGE=1
const FIRE_TRAIL_FIRE_DURATION = GameplayConstants.DEBUFF_STANDART_LIFETIME
const FIRE_TRAIL_SCALING=1.2

const FIRE_AMMO_TICK_DAMAGE=5
const FIRE_AMMO_FIRE_DURATION = GameplayConstants.DEBUFF_STANDART_LIFETIME
const FIRE_AMMO_SCALING=1.2

const POISON_AMMO_TICK_DAMAGE=5000
const POISON_AMMO_FIRE_DURATION = GameplayConstants.DEBUFF_STANDART_LIFETIME
const POISON_AMMO_SCALING=1.2
const POISON_AMMO_PROPAGATION_TIME=2

const EXPLOSIVE_UNIT_HEALTH_PERCENTAGE_DAMAGE=0.25
const EXPLOSIVE_UNIT_SCALING=1.5
const EXPLOSIVE_UNIT_EXPLOSION_RANGE=2

const VOODOO_KILL_CHANCE=25

const OVERCHARGE_COOLDOWN_REDUCTION=40
const OVERCHARGE_SCALING=1.1
const OVERCHARGE_BUFF_DURATION=3

const FORKING_DEGREE=22.5

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
	color=ModType.values()[type-1]
	color+=1
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
