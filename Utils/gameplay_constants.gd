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
const base = TurretBaseMod.ModType.BASE
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
	
	FireTrailMod: d(tiny, proj, ItemBlockConstants.YELLOW_TILE_ID),
	MultipleShotsMod:d(l,proj, ItemBlockConstants.YELLOW_TILE_ID),
	PenetratingAmmunition:d(o,proj, ItemBlockConstants.YELLOW_TILE_ID),
	FrostTrailMod:d(small,proj, ItemBlockConstants.YELLOW_TILE_ID),
	GhostProjectileMod:d(small,proj, ItemBlockConstants.YELLOW_TILE_ID),
	
	ForkingAmmunitionMod: d(arrow, ammo, ItemBlockConstants.RED_TILE_ID),
	ExplosiveAmmunition:d(cross,ammo, ItemBlockConstants.RED_TILE_ID),
	FireAmmunitionMod:d(tiny,ammo, ItemBlockConstants.RED_TILE_ID),
	FrostAmmunitionMod:d(small,ammo, ItemBlockConstants.RED_TILE_ID),
	LightningAmmunitionMod:d(small,ammo, ItemBlockConstants.RED_TILE_ID),
	PoisonAmmunitionMod:d(small,ammo, ItemBlockConstants.RED_TILE_ID),
	
	FrozenBloodKillMod:d(arrow,kill, ItemBlockConstants.MAGENTA_TILE_ID),
	ExplosiveUnitMod:d(o,kill, ItemBlockConstants.MAGENTA_TILE_ID),
	RegenerateKillMod:d(cross,kill, ItemBlockConstants.MAGENTA_TILE_ID),
	StunningKillMod:d(s,kill, ItemBlockConstants.MAGENTA_TILE_ID),
	VoodooKillMod:d(s,kill, ItemBlockConstants.MAGENTA_TILE_ID),
	OverchargeKillMod:d(cross,kill, ItemBlockConstants.MAGENTA_TILE_ID),
	
	AirBlockMod:d(s,base, ItemBlockConstants.WHITE_TILE_ID),
	AirAttackMod:d(s,base, ItemBlockConstants.WHITE_TILE_ID),
	AirAndGroundAttackMod:d(cross,base, ItemBlockConstants.WHITE_TILE_ID),
	WallhackMod:d(tiny,base, ItemBlockConstants.WHITE_TILE_ID),
	StackIncreaseMod:d(o,base, ItemBlockConstants.WHITE_TILE_ID)
	
	
	
	
	
}
static func register_mods_for_sim():
	for mod in turret_mods.keys():
		var type=turret_mods[mod].type
		if !TurretBaseMod.implemented_mods.has(type):TurretBaseMod.implemented_mods[type]=[]
		TurretBaseMod.implemented_mods[type].append(mod)
	pass;
static func d(shape, type, tile_id):
	return data.new(shape, type, tile_id)
class data:
	var shape:Block.BlockShape
	var type:TurretBaseMod.ModType
	var tile_id:int

	func _init(shape, type, tile_id):
		self.shape = shape
		self.type = type
		self.tile_id = tile_id
		
const green_poison_decay = 1;

const playerHP = 200;
const playerMaxHP = 200;

const entity_collision_precision = 24
