extends Node
class_name Stats;
static var block_size=64;
static var board_width=16;
static var board_height=16;

static var base_range=10;
static var green_range=2*base_range;
static var blue_range=2*base_range;
static var yellow_range=10*base_range;
static var red_range=0.2*base_range;
static var grey_range=2*base_range;

static var red_laser_range=1*base_range;
static var blue_laser_range=3*base_range;
static var green_poison_range=2*base_range;

static var base_missile_speed=1000;
static var green_missile_speed=1*base_missile_speed;
static var blue_missile_speed=2*base_missile_speed;
static var yellow_missile_speed=10*base_missile_speed;
static var red_missile_speed=1*base_missile_speed;
static var grey_missile_speed=2*base_missile_speed;

static var blue_laser_missile_speed=base_missile_speed*4;
static var red_laser_missile_speed=base_missile_speed*1;
static var green_poison_missile_speed=base_missile_speed*1;


static var base_cooldown=1;
static var green_cooldown=base_cooldown*3;
static var blue_cooldown=base_cooldown*0.5;
static var yellow_cooldown=base_cooldown*2;
static var grey_cooldown=base_cooldown*1;
static var red_cooldown=base_cooldown*0.3;

static var red_laser_cooldown=base_cooldown*0.5;
static var blue_laser_cooldown=base_cooldown*0.3;
static var green_poison_cooldown=base_cooldown*1.5

static var base_damage=5;
static var green_damage=base_damage*1;
static var blue_damage=base_damage*2;
static var yellow_damage=base_damage*3;
static var grey_damage=base_damage*1;
static var red_damage=base_damage*1;

static var red_laser_damage=base_damage*0.5;
static var blue_laser_damage=base_damage*1;
static var green_poison_damage=base_damage*1;

static var base_penetrations=1;
static var green_penetrations=base_penetrations*1;
static var blue_penetrations=base_penetrations*1;
static var yellow_penetrations=base_penetrations*1;
static var grey_penetrations=base_penetrations*1;
static var red_penetrations=base_penetrations*-1000000;

static var red_laser_penetrations=base_penetrations*1;
static var blue_laser_penetrations=base_penetrations*5;
static var green_poison_penetrations=base_penetrations*1;


static var green_explosion_range=0.5;
static var red_laser_damage_stack=0.05;
static var green_poison_damage_stack=1;

static var green_glowing=false;
static var blue_glowing=false;
static var yellow_glowing=false;
static var grey_glowing=false;
static var red_glowing=false;

static var red_laser_glowing=true;
static var blue_laser_glowing=true;
static var green_poison_glowing=false;

static var poison_dropoff_rate=3;
static var poison_propagation_rate=3;
static var poison_propagation_range=base_range*0.3
static var green_poison_decay=1;

static var enemy_base_HP=500000;
static var GREEN_enemy_HP=enemy_base_HP*3;
static var BLUE_enemy_HP=enemy_base_HP*1;
static var YELLOW_enemy_HP=enemy_base_HP*0.5;
static var RED_enemy_HP=enemy_base_HP*2;

static var enemy_base_damage=500;
static var GREEN_enemy_damage=enemy_base_damage*1;
static var BLUE_enemy_damage=enemy_base_damage*1;
static var YELLOW_enemy_damage=enemy_base_damage*2;
static var RED_enemy_damage=enemy_base_damage*3;

static var enemy_base_speed=1;
static var GREEN_enemy_speed=enemy_base_speed*1;
static var BLUE_enemy_speed=enemy_base_speed*1;
static var YELLOW_enemy_speed=enemy_base_speed*3;
static var RED_enemy_speed=enemy_base_speed*0.5;



static var playerHP=100;
static var playerMaxHP=200;

static var FIREBALL_damage=500;
static var FIREBALL_range=1;
static var FIREBALL_phase=GamePhase.BATTLE
static var FIREBALL_instant=false;

static var CRYOBALL_damage=100;
static var CRYOBALL_range=1;
static var CRYOBALL_phase=GamePhase.BATTLE
static var CRYOBALL_instant=false;
static var CRYOBALL_slowFactor=0.5;
static var CRYOBALL_slowDuration=10;


#damage for simplicity of call, it heals you, doesnt damage you. range==multiplicator for each round held
static var HEAL_damage=25;
static var HEAL_range=2;
static var HEAL_max_HeldRounds=5;
static var HEAL_instant=true;
static var HEAL_phase=GamePhase.BOTH
#analog to heal
static var UPHEALTH_damage=5;
static var UPHEALTH_range=2;
static var UPHEALTH_max_HeldRounds=5;
static var UPHEALTH_instant=true;
static var UPHEALTH_phase=GamePhase.BOTH

static var BULLDOZER_phase=GamePhase.BUILD
static var BULLDOZER_instant=true;
#x axis
static var BULLDOZER_damage=2;
#y axis
static var BULLDOZER_range=2;

static var GLUE_phase=GamePhase.BATTLE
static var GLUE_range=GamePhase.BATTLE
static var GLUE_instant=false;
static var GLUE_slowFactor=0.5;
static var GLUE_Duration=10;


static var POISON_damage=100;
static var POISON_range=0.5;
static var POISON_phase=GamePhase.BATTLE
static var POISON_instant=false;
static var POISON_decay=5;
static var POISON_description="A quickly decaying, very potent, spreading toxin"


static var MOVE_phase=GamePhase.BUILD;
static var MOVE_instant=true;

enum TurretColor {GREY=1, GREEN=2, RED=3, YELLOW=4,BLUE=5};
enum TurretExtension {DEFAULT=1,REDLASER=2, BLUELASER=3, YELLOWCATAPULT=4, GREENPOISON=5};
enum GamePhase {BATTLE=1,BUILD=2,BOTH=3};
enum SpecialCards {HEAL=1,FIREBALL=2,UPHEALTH=3,CRYOBALL=4,MOVE=5, BULLDOZER=6,GLUE=7,POISON=8}
enum BlockShape {O=1, I=2, S=3, Z=4, L=5, J=6, T=7, TINY=8, SMALL=9, ARROW=10, CROSS=11}
enum Catastrophies {METEOR=1,SWITCH=2,EXPAND=3,ADDSPAWNER=4,EARTHQUAKE=5}



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
static func getStringFromEnum(type:TurretColor):
	return Stats.TurretColor.keys()[(type)-1];
	match type:
		1: return "GREY";
		2: return "GREEN";
		3: return "RED";
		4: return "YELLOW";
		5: return "BLUE"
	pass
static func getStringFromEnumLowercase(type:TurretColor):
	return Stats.TurretColor.keys()[(type)-1].to_lower();
	match type:
		1: return "grey";
		2: return "green";
		3: return "red";
		4: return "yellow";
		5: return "blue"
	pass
static func getStringFromSpecialCardEnum(name:SpecialCards):
	return Stats.SpecialCards.keys()[(name)-1];
	match name:
		1: return "HEAL";
		2: return "FIREBALL";
		3: return "UPHEALTH";
		4: return "CRYOBALL";
		5: return "MOVE"
		6: return "BULLDOZER"
	pass;
static func getStringFromEnumExtension(type:TurretExtension):
	
	match type:
		1: return ""
		2: return "LASER"
		3: return "LASER"
		5: return "POISON"
	
	return "";
static func getStringFromEnumExtensionLowercase(type:TurretExtension):
	return getStringFromEnumExtension(type).to_lower()
	match type:
		1: return ""
		2: return "laser"
		3: return "laser"
		5: return "poison"
		
	
	return "";
static func getColorFromLowercaseString(str:String):
	match str:
		"red":return TurretColor.RED;
		"blue":return TurretColor.BLUE;
		"green":return TurretColor.GREEN;
		"yellow":return TurretColor.YELLOW;
		"grey":return TurretColor.GREY;
	pass;
static func getColorFromString(str:String):
	match str:
		"RED":return TurretColor.RED;
		"BLUE":return TurretColor.BLUE;
		"GREEN":return TurretColor.GREEN;
		"YELLOW":return TurretColor.YELLOW;
		"GREY":return TurretColor.GREY;
	pass;
static func getShapeFromString(str:String):
	match str:
		"O":return BlockShape.O
		"I":return BlockShape.I
		"S":return BlockShape.S
		"Z":return BlockShape.Z
		"L":return BlockShape.L
		"J":return BlockShape.J
		"T":return BlockShape.T
		"TINY":return BlockShape.TINY
		"SMALL":return BlockShape.SMALL
		"ARROW":return BlockShape.ARROW
		"CROSS":return BlockShape.CROSS
	pass;
static func getProperty(type:TurretColor,extension:TurretExtension,property:String):
	var color=getStringFromEnumLowercase(type);
	var ext=getStringFromEnumExtensionLowercase(extension);
	var temp;
	if extension==TurretExtension.DEFAULT:
		temp = Stats.new().get(color+"_"+property);
	else:
		temp = Stats.new().get(color+"_"+ext+"_"+property);
	return temp;
static func getMaxRoundsHeld(type:SpecialCards):
	return Stats.new().get(getStringFromSpecialCardEnum(type)+"_max_HeldRounds") 

static func getEnemyProperty(type:TurretColor,prop):
	return Stats.new().get(getStringFromEnum(type)+"_enemy_"+prop) 
	

	
static func getCardDamage(type:SpecialCards):
	return Stats.new().get(getStringFromSpecialCardEnum(type)+"_damage")
	
static func getCardRange(type:SpecialCards):
	return Stats.new().get(getStringFromSpecialCardEnum(type)+"_range")
	
static func getCardInstant(type:SpecialCards):
	return Stats.new().get(getStringFromSpecialCardEnum(type)+"_instant")

static func getCardPhase(type:SpecialCards):
	return Stats.new().get(getStringFromSpecialCardEnum(type)+"_phase")
static func get_generic_property(arr):
	var str=""
	for a in arr:
		str=str+a+"_";
	str.erase(str.length() - 1, 1)
	return Stats.new().get(str)
	pass;
	
static func getCooldown(type:TurretColor,extension:TurretExtension):
	return getProperty(type,extension,"cooldown");

static func getDamage(type:TurretColor,extension:TurretExtension):
	return getProperty(type,extension,"damage");
static func getGlowing(type:TurretColor,extension:TurretExtension):
	return getProperty(type,extension,"glowing");

static func getMissileSpeed(type:TurretColor,extension:TurretExtension):
	return getProperty(type,extension,"missile_speed");

static func getOneshotType(type:TurretColor,extension:TurretExtension):
	return getProperty(type,extension,"penetrations");

static func getRange(type:TurretColor,extension:TurretExtension):
	return getProperty(type,extension,"range")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
static func getRandomBlock(lvl):
	var rng=RandomNumberGenerator.new()
	var color=TurretColor.values()[rng.randi_range(0,TurretColor.size()-1)]
	color=Stats.TurretColor.BLUE
	var extension=TurretExtension.values()[rng.randi_range(0,TurretExtension.size()-1)]
	var block=BlockShape.values()[rng.randi_range(0,BlockShape.size()-1)]
	return getBlockFromShape(block,color,lvl,extension)		
static func getBlockFromShape(shape: BlockShape, color: TurretColor, level: int = 1, extenstion: TurretExtension = TurretExtension.DEFAULT) -> Block:
	var pieces = []
	match shape:
		BlockShape.O:
			pieces = [
				Block.Piece.new(Vector2(0,0), color, level, extenstion),
				Block.Piece.new(Vector2(-1,0), color, level, extenstion),
				Block.Piece.new(Vector2(-1,-1), color, level, extenstion),
				Block.Piece.new(Vector2(0,-1), color, level, extenstion)
			]
		BlockShape.I:
			pieces = [
				Block.Piece.new(Vector2(0,0), color, level, extenstion),
				Block.Piece.new(Vector2(0,1), color, level, extenstion),
				Block.Piece.new(Vector2(0,-1), color, level, extenstion),
				Block.Piece.new(Vector2(0,-2), color, level, extenstion)
			]
		BlockShape.S:
			pieces = [
				Block.Piece.new(Vector2(0,0), color, level, extenstion),
				Block.Piece.new(Vector2(-1,0), color, level, extenstion),
				Block.Piece.new(Vector2(0,1), color, level, extenstion),
				Block.Piece.new(Vector2(1,1), color, level, extenstion)
			]
		BlockShape.Z:
			pieces = [
				Block.Piece.new(Vector2(0,0), color, level, extenstion),
				Block.Piece.new(Vector2(1,0), color, level, extenstion),
				Block.Piece.new(Vector2(0,-1), color, level, extenstion),
				Block.Piece.new(Vector2(-1,-1), color, level, extenstion)
			]
		BlockShape.L:
			pieces = [
				Block.Piece.new(Vector2(0,0), color, level, extenstion),
				Block.Piece.new(Vector2(0,1), color, level, extenstion),
				Block.Piece.new(Vector2(0,-1), color, level, extenstion),
				Block.Piece.new(Vector2(1,1), color, level, extenstion)
			]
		BlockShape.J:
			pieces = [
				Block.Piece.new(Vector2(0,0), color, level, extenstion),
				Block.Piece.new(Vector2(0,1), color, level, extenstion),
				Block.Piece.new(Vector2(0,-1), color, level, extenstion),
				Block.Piece.new(Vector2(-1,1), color, level, extenstion)
			]
		BlockShape.T:
			pieces = [
				Block.Piece.new(Vector2(0,0), color, level, extenstion),
				Block.Piece.new(Vector2(-1,0), color, level, extenstion),
				Block.Piece.new(Vector2(1,0), color, level, extenstion),
				Block.Piece.new(Vector2(0,1), color, level, extenstion)
			]
		BlockShape.TINY:
			pieces = [
				Block.Piece.new(Vector2(0,0), color, level, extenstion),
			]
		BlockShape.SMALL:
			pieces = [
				Block.Piece.new(Vector2(0,0), color, level, extenstion),
				Block.Piece.new(Vector2(0,-1), color, level, extenstion)
			]
		BlockShape.ARROW:
			pieces = [
				Block.Piece.new(Vector2(0,0), color, level, extenstion),
				Block.Piece.new(Vector2(-1,0), color, level, extenstion),
				Block.Piece.new(Vector2(0,1), color, level, extenstion)
			]
		BlockShape.CROSS:
			pieces = [
				Block.Piece.new(Vector2(0,0), color, level, extenstion),
				Block.Piece.new(Vector2(0,-1), color, level, extenstion),
				Block.Piece.new(Vector2(1,0), color, level, extenstion),
				Block.Piece.new(Vector2(0,1), color, level, extenstion),
				Block.Piece.new(Vector2(-1,0), color, level, extenstion)
			]
		
	return Block.new(pieces)
