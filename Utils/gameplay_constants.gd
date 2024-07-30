extends GameObjectCounted
class_name GameplayConstants

const CAMERA_MOVE_DURATION = 2
const MAX_TURRET_LEVEL = 5
const CARD_PLACEMENT_DELAY = 0.2

const MIN_NUMBER_OF_WAVES = 1
const MAX_NUMBER_OF_WAVES = 100
const MAX_NUMBER_OF_MONSTERS_PER_TYPE = 50

const DEBUFF_STANDART_LIFETIME = 3

const green_explosion_range = 0.5;
const red_laser_damage_stack = 3;
const green_poison_damage_stack = 6;
const blue_freezer_slow_amount = 0.7
const blue_freezer_slow_duration = 1


const poison_dropoff_rate = 3;
const poison_propagation_rate = 3;
enum ModType {BASE, HULL, PROJECTILE, AMMUNITION, PRODUCTION, ONKILL}
const target = TurretBaseMod.ModType.BASE
const hull = TurretBaseMod.ModType.HULL
const proj = TurretBaseMod.ModType.PROJECTILE
const ammo = TurretBaseMod.ModType.AMMUNITION
const prod = TurretBaseMod.ModType.PRODUCTION
const kill = TurretBaseMod.ModType.ONKILL

const arrow = Block.BlockShape.ARROW
const o = Block.BlockShape.O
const i = Block.BlockShape.I
const s = Block.BlockShape.S
const z = Block.BlockShape.Z
const l = Block.BlockShape.L
const j = Block.BlockShape.J
const t = Block.BlockShape.T
const tiny = Block.BlockShape.TINY
const small = Block.BlockShape.SMALL
const cross = Block.BlockShape.CROSS

static func get_mod_data(mod)->data:
	return turret_mods[mod.get_script()]
	pass;
static var turret_mods = {
	ForkingAmmunitionMod: d(arrow, ammo),
	FireTrailMod: d(tiny, proj),
	MultipleShotsMod:d(l,proj),
	PenetratingAmmunition:d(o,proj),
	FireTrailMod:d(small,proj),
	FrostTrailMod:d(small,proj),
	ExplosiveAmmunition:d(cross,ammo),
	
}
static func d(shape, type):
	return data.new(shape, type)
class data:
	var shape:Block.BlockShape
	var type:TurretBaseMod.ModType

	func _init(shape, type):
		self.shape = shape
		self.type = type
const green_poison_decay = 1;

const playerHP = 200;
const playerMaxHP = 200;

const entity_collision_precision = 24
