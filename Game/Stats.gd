extends Node
class_name Stats;
const block_size=62;

static var board_extend_height=10;
static var board_cave_chance_percent=50
static var board_cave_deepness=util.Distance.new(4,10)
static var board_cave_spawner_chance_percent=75

const CAMERA_MOVE_DURATION=2
const CATASTROPHY_PREVIEW_DURATION=1

const MAX_TURRET_LEVEL=5

const base_range=2;
const green_range=2*base_range;
const blue_range=2*base_range;
const yellow_range=10*base_range;
const red_range=0.4*base_range;
const grey_range=2*base_range;

const red_laser_range=1*base_range;
const blue_laser_range=3*base_range;
const green_poison_range=2*base_range;
const yellow_mortar_range=10*base_range;

const base_missile_speed=750;
const green_missile_speed=1*base_missile_speed;
const blue_missile_speed=1*base_missile_speed;
const yellow_missile_speed=3*base_missile_speed;
const red_missile_speed=1*base_missile_speed;
const grey_missile_speed=2*base_missile_speed;

const blue_laser_missile_speed=base_missile_speed*3;
const red_laser_missile_speed=base_missile_speed*1;
const green_poison_missile_speed=base_missile_speed*1;
const yellow_mortar_missile_speed=base_missile_speed;


const base_cooldown=1.2;
const green_cooldown=base_cooldown*3;
const blue_cooldown=base_cooldown*2;
const yellow_cooldown=base_cooldown*3.04;
const grey_cooldown=base_cooldown*1;
const red_cooldown=base_cooldown*0.3;

const red_laser_cooldown=base_cooldown*0.5;
const blue_laser_cooldown=base_cooldown*0.6;
const green_poison_cooldown=base_cooldown*1.5
const yellow_mortar_cooldown=base_cooldown*3;

const base_damage=5;
const green_damage=base_damage*7;
const blue_damage=base_damage*8;
const yellow_damage=base_damage*5;
const grey_damage=base_damage*1;
const red_damage=base_damage*2;

const red_laser_damage=base_damage*0.5;
const blue_laser_damage=base_damage*2;
const green_poison_damage=base_damage*1;
const yellow_mortar_damage=base_damage*4;

const base_penetrations=1;
const green_penetrations=base_penetrations*1;
const blue_penetrations=base_penetrations*1;
const yellow_penetrations=base_penetrations*-1000000;
const grey_penetrations=base_penetrations*1;
const red_penetrations=base_penetrations*-1000000;

const red_laser_penetrations=base_penetrations*1;
const blue_laser_penetrations=base_penetrations*3;
const green_poison_penetrations=base_penetrations*1;

const green_instanthit=false;
const blue_instanthit=false;
const red_instanthit=true;
const yellow_instanthit=true;

const red_laser_instanthit=true;
const blue_laser_instanthit=false;
const green_poison_instanthit=false;
const yellow_mortar_instanthit=true;


const yellow_mortar_penetrations=1;
const green_explosion_range=0.5;
const red_laser_damage_stack=1;
const green_poison_damage_stack=3;

const green_glowing=false;
const blue_glowing=false;
const yellow_glowing=false;
const grey_glowing=false;
const red_glowing=false;

const red_laser_glowing=false;
const blue_laser_glowing=true;
const green_poison_glowing=false;
const yellow_mortar_glowing=false;


const poison_dropoff_rate=3;
const poison_propagation_rate=3;
const poison_propagation_range=base_range*0.3
const green_poison_decay=1;

static var enemy_base_HP:float=150;
static var GREEN_enemy_HP=enemy_base_HP*1.75;
static var BLUE_enemy_HP=enemy_base_HP*1;
static var YELLOW_enemy_HP=enemy_base_HP*0.7;
static var RED_enemy_HP=enemy_base_HP*1.5;

const enemy_base_damage=5;
const GREEN_enemy_damage=enemy_base_damage*1;
const BLUE_enemy_damage=enemy_base_damage*1;
const YELLOW_enemy_damage=enemy_base_damage*2;
const RED_enemy_damage=enemy_base_damage*3;


const max_enemies_per_spawner=50;

const enemy_base_speed_factor =1;
const enemy_base_speed=8;
const enemy_base_acceleration = 7;
const GREEN_enemy_speed=enemy_base_speed*1;
const BLUE_enemy_speed=enemy_base_speed*1;
const YELLOW_enemy_speed=enemy_base_speed*1.5;
const RED_enemy_speed=enemy_base_speed*0.7;

static var enemy_base_exp=10;
static var enemy_scaling=0.45;

const playerHP=200;
const playerMaxHP=200;

const FIREBALL_damage=9999999;
const FIREBALL_range=1;
const FIREBALL_phase=GamePhase.BATTLE
const FIREBALL_instant=false;

const CRYOBALL_damage=100;
const CRYOBALL_range=2;
const CRYOBALL_phase=GamePhase.BATTLE
const CRYOBALL_instant=false;
const CRYOBALL_slowFactor=0.2;
const CRYOBALL_slowDuration=10;

#damage for simplicity of call, it heals you, doesnt damage you. range==multiplicator for each round held
const HEAL_damage=25;
const HEAL_range=2;
const HEAL_max_HeldRounds=5;
const HEAL_instant=true;
const HEAL_phase=GamePhase.BOTH
#analog to heal
const UPHEALTH_damage=5;
const UPHEALTH_range=2;
const UPHEALTH_max_HeldRounds=5;
const UPHEALTH_instant=true;
const UPHEALTH_phase=GamePhase.BOTH

const BULLDOZER_phase=GamePhase.BUILD
const BULLDOZER_instant=true;
#x axis
const BULLDOZER_damage=2;
#y axis
const BULLDOZER_range=2;

const GLUE_phase=GamePhase.BATTLE
const GLUE_range=GamePhase.BATTLE
const GLUE_instant=false;
const GLUE_slowFactor=0.5;
const GLUE_Duration=10;

static var rng=RandomNumberGenerator.new()
const POISON_damage=100;
const POISON_range=1;
const POISON_phase=GamePhase.BATTLE
const POISON_instant=false;
const POISON_decay=5;
const POISON_description="A quickly decaying, very potent, spreading toxin"

const UPDRAW_instant=true;
const UPDRAW_phase=GamePhase.BOTH;
const UPMAXCARDS_instant=true;
const UPMAXCARDS_phase=GamePhase.BOTH;

const MOVE_phase=GamePhase.BUILD;
const MOVE_instant=true;


static var bulldozer_catastrophy_width=5
static var bulldozer_catastrophy_height=5

static var drill_catastrophy_width=3

static var level_down_catastrophy_width=5
static var level_down_catastrophy_height=5

static var colorchanger_catastrophy_width=3
static var colorchanger_catastrophy_height=3

static var GREY_description="This gray block does not spawn turrets. But you can place it anywhere you like!"
static var BLUE_description="A blue turret firing regular bullets at a medium rate."
static var RED_description="A red saw dealing high damage to close enemies."
static var GREEN_description="A green rocket launcher dealing damage to many enemies."
static var YELLOW_description="A yellow sniper dealing damage from afar."
static var BLUELASER_description="A blue turret shoots lasers that perforate multiple enemies."
static var REDLASER_description="A red laser that deals high damage to a single enemy."
static var GREENPOISON_description="A green turret applies a spreading toxin to enemies."
static var YELLOWMORTAR_description="A yellow turret shoots explosives at a high range."
static var HEAL_description="Heals you. The longer you hold the card, the more heal you get."
static var FIREBALL_description="Deals damage to many enemies."
static var UPHEALTH_description="Increases your maximum health. The longer you hold the card, the more the amount. "
static var CRYOBALL_description="Damages and slows enemies. "
static var MOVE_description="Allows you to move built blocks."
static var BULLDOZER_description="Allows you to destroy blocks."
static var GLUE_description="Slows enemies while they are on it."
static var UPDRAW_description="Increases the number of cards you draw per round."
static var UPMAXCARDS_description="Increases the number of cards you can hold."
const CARD_PLACEMENT_DELAY=0.2

static var BLUE_name="Pew Pew"
static var RED_name="Saw"
static var GREEN_name="Rocket Launcher"
static var YELLOW_name="Sniper"
static var GREY_name="Grey block"
static var BLUELASER_name="Laser"
static var REDLASER_name="Red laser"
static var GREENPOISON_name="Toxicator"
static var YELLOWMORTAR_name="Mortar"

static var BLUELASER_big_description="A blue laser turret shoots lasers that pass through multiple enemies. It stops after damaging three.   "
static var REDLASER_big_description="A red laser turret that deals high damage to a single enemy. The more lasers shoot the same enemy, the more damage he takes."
static var GREENPOISON_big_description="A green turret applies a toxin to enemies, dealing damage over time. It stacks on each consecutive application!"
static var YELLOWMORTAR_big_description="A yellow turret shoots explosives at a high range. First, the target location is set, and after a second it hits."

static var HEAL_big_description="Heals you. The longer you hold it in your hand, the more it heals you. Trust me, you will need it!"
static var FIREBALL_big_description="Casts a powerful fireball at your target location. Can be used to catch stray enemies. "
static var UPHEALTH_big_description="Increases your maximum health. Again, if you hold it for longer, the amount will increase."
static var CRYOBALL_big_description="Casts a freezing nova. This slows your enemies, so make sure youre turrets will benefit from that!"
static var MOVE_big_description="Move around your set blocks! You can even rotate them. Picks up all connected blocks. "
static var BULLDOZER_big_description="This card allows you to destroy blocks! But use it wisely: you wont get them back. "
static var GLUE_big_description="Bring out the big tubes! Slows enemies on top of this slimey puddle."
static var POISON_big_description="Poisons enemies you hit with it. Don't worry, its not contagious."
static var UPDRAW_big_description="It's dangerous to build alone. Take this! 
(lets you draw more cards)"
static var UPMAXCARDS_big_description="Lets you hold more cards. It's magical. "
enum TurretColor {GREY=1, GREEN=2, RED=3, YELLOW=4,BLUE=5};
enum TurretExtension {DEFAULT=1,REDLASER=2, BLUELASER=3, YELLOWMORTAR=4, GREENPOISON=5};
enum GamePhase {BATTLE=1,BUILD=2,BOTH=3};
enum SpecialCards {HEAL=1,FIREBALL=2,UPHEALTH=3,CRYOBALL=4,MOVE=5, BULLDOZER=6,GLUE=7,POISON=8, UPDRAW=9, UPMAXCARDS=10}
enum BlockShape {O=1, I=2, S=3, Z=4, L=5, J=6, T=7, TINY=8, SMALL=9, ARROW=10, CROSS=11}
enum Catastrophies {COLORCHANGER=1, DRILL=2, LEVELDOWN=6, BULLDOZER=7}
static var COLORCHANGER_name="Color Changer!"
static var DRILL_name="Drill!"
static var LEVELDOWN_name="Level down!"
static var BULLDOZER_name="Meteor!"
static var stats=Stats.new()
var map;
static func getCatName(cat):
	return stats.get(cat+"_name")
	
	pass;
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
static func getDescription(v:String):
	
	return stats.get(v+"_description")	
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
		4: return "MORTAR"
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
		"WALL":return -3
	pass;

static func getEnumFromString(str:String):
	match str:
		"DEFAULT":return TurretExtension.DEFAULT
		"REDLASER":return TurretExtension.REDLASER
		"BLUELASER":return TurretExtension.BLUELASER
		"YELLOWMORTAR":return TurretExtension.YELLOWMORTAR
		"GREENPOISON":return TurretExtension.GREENPOISON
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
	if stats.map==null:
		stats.map=stats.get_script().get_script_constant_map()
	if extension==TurretExtension.DEFAULT:
		#temp = stats.get(color+"_"+property);
		temp=stats.map[color+"_"+property]
	else:
		temp=stats.map[color+"_"+ext+"_"+property]
		
	return temp;
static func getMaxRoundsHeld(type:SpecialCards):
	return stats.get(getStringFromSpecialCardEnum(type)+"_max_HeldRounds") 

static func getEnemyProperty(type:TurretColor,prop):
	return stats.get(getStringFromEnum(type)+"_enemy_"+prop) 
	

	
static func getCardDamage(type:SpecialCards):
	return stats.get(getStringFromSpecialCardEnum(type)+"_damage")
	
static func getCardRange(type:SpecialCards):
	return stats.get(getStringFromSpecialCardEnum(type)+"_range")
	
static func getCardInstant(type:SpecialCards):
	return stats.get(getStringFromSpecialCardEnum(type)+"_instant")

static func getCardPhase(type:SpecialCards):
	return stats.get(getStringFromSpecialCardEnum(type)+"_phase")
static func get_generic_property(arr):
	var str=""
	for a in arr:
		str=str+a+"_";
	str.erase(str.length() - 1, 1)
	return stats.get(str)
	pass;
	
static func getCooldown(type:TurretColor,extension:TurretExtension):
	return getProperty(type,extension,"cooldown");
static func getInstantHit(type:TurretColor,extension:TurretExtension):
	return getProperty(type,extension,"instanthit");
	
	
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

static func getiterativeColor(skip:int=10):
	colorit=(colorit+1)%5
	if colorit==skip:
		colorit=skip+1;
	#util.p(Stats.TurretColor.keys()[colorit])
	return Stats.TurretColor.values()[colorit];
	
	pass;
	
	
static var colorit=1;
static var counter=0;


static var specialCardChance =10; #chance whether for a special card !specialCardChance = chance for Block Card
static var extensionChance = 50; #chance if a color get's the extrension

static func getRandomCard(gamestate):
	var card;
	var rng=RandomNumberGenerator.new()
	numberOfCardsDrawn=numberOfCardsDrawn+1;
	if numberOfPiecesDrawn/numberOfCardsDrawn<TargetPieceAverage-tolerance:
		return BlockCard.create(gamestate)
	if (rng.randi_range(0,100) < specialCardChance):
		card=SpecialCard.create(gamestate)
	else:
		card= BlockCard.create(gamestate)
	return card;	

static func getRandomCatastrophy():
	return Catastrophies.keys()[rng.randi_range(0,Catastrophies.size()-1)]
static func getRandomColor(gamestate):
	var sum = 0	
	var color = getiterativeColor()
	var chance = rng.randi_range(0,100)

	var colorChances=gamestate.getColorChances()
	for i in colorChances.size():
		sum += colorChances[i]
		if chance < sum:
			color= TurretColor.values()[i]
			break;
	return color		
		
		

			
func getRandomBlock(lvl,gamestate):
	#TODO: add card chances
	var rng=RandomNumberGenerator.new()
	var color=getRandomColor(gamestate)
	
			
	var extension=TurretExtension.DEFAULT
	if gamestate.unlockedExtensions.size() != 0 && color != TurretColor.GREY:
		for ex in gamestate.unlockedExtensions.size():
			if gamestate.unlockedExtensions[ex] == getExtensionFromColor(color):
				if rng.randi_range(0,100) < extensionChance:
					extension = getExtensionFromColor(color)
	
	var block=getEvaluatedShape(0)
	
	
	return getBlockFromShape(block,color,lvl,extension)
	#return getBlockFromShape(block,TurretColor.YELLOW,lvl,TurretExtension.YELLOWMORTAR)
static var numberOfPiecesDrawn:float=1;
static var numberOfCardsDrawn:float=1;
static var TargetPieceAverage:float=3.5;
static var tolerance:float=0.5

static var bestCurrentShape=null;
static var bestCurrentAverage=1;
	
func getEvaluatedShape(counter):
	var shape=BlockShape.values()[rng.randi_range(0,BlockShape.size()-1)]
	var block=getBlockFromShape(shape,0,0);
	var currentPieces=+numberOfPiecesDrawn+block.pieces.size()
	var currentAverage=currentPieces/numberOfCardsDrawn 
	
	if bestCurrentAverage != null and currentAverage>bestCurrentAverage:
		bestCurrentAverage=currentAverage
		bestCurrentShape=shape
	var difference=currentAverage-TargetPieceAverage
	
	if counter>20:
		numberOfPiecesDrawn=numberOfPiecesDrawn+block.pieces.size();
		return bestCurrentShape;
	if abs(difference)>tolerance:
		return getEvaluatedShape(counter+1)
		
	numberOfPiecesDrawn=numberOfPiecesDrawn+block.pieces.size();	
	return shape;	
static func getExtensionFromColor(color: TurretColor):
	match color:
		1: return TurretExtension.DEFAULT;
		2: return TurretExtension.GREENPOISON;
		3: return TurretExtension.REDLASER;
		4: return TurretExtension.YELLOWMORTAR;	#TODO: it's actually TurretExtension.YELLOWCATAPULT but it's not implemented yet
		5: return TurretExtension.BLUELASER
	pass	


		
static func getName(name):
	return stats.get(name+"_name");
static func getBigDescription(name):
	return stats.get(name+"_big_description");
		
		

static func getBlockFromShape(shape: BlockShape, color: TurretColor, level: int = 1, extension: TurretExtension = TurretExtension.DEFAULT) -> Block:
	var pieces = []
	match shape:
		BlockShape.O:
			pieces = [
				Block.Piece.new(Vector2(0,0), color, level, extension),
				Block.Piece.new(Vector2(-1,0), color, level, extension),
				Block.Piece.new(Vector2(-1,-1), color, level, extension),
				Block.Piece.new(Vector2(0,-1), color, level, extension)
			]
		BlockShape.I:
			pieces = [
				Block.Piece.new(Vector2(0,0), color, level, extension),
				Block.Piece.new(Vector2(0,1), color, level, extension),
				Block.Piece.new(Vector2(0,-1), color, level, extension),
				Block.Piece.new(Vector2(0,-2), color, level, extension)
			]
		BlockShape.S:
			pieces = [
				Block.Piece.new(Vector2(0,0), color, level, extension),
				Block.Piece.new(Vector2(-1,0), color, level, extension),
				Block.Piece.new(Vector2(0,-1), color, level, extension),
				Block.Piece.new(Vector2(1,-1), color, level, extension)
			]
		BlockShape.Z:
			pieces = [
				Block.Piece.new(Vector2(0,0), color, level, extension),
				Block.Piece.new(Vector2(1,0), color, level, extension),
				Block.Piece.new(Vector2(0,-1), color, level, extension),
				Block.Piece.new(Vector2(-1,-1), color, level, extension)
			]
		BlockShape.L:
			pieces = [
				Block.Piece.new(Vector2(0,0), color, level, extension),
				Block.Piece.new(Vector2(0,1), color, level, extension),
				Block.Piece.new(Vector2(0,-1), color, level, extension),
				Block.Piece.new(Vector2(1,1), color, level, extension)
			]
		BlockShape.J:
			pieces = [
				Block.Piece.new(Vector2(0,0), color, level, extension),
				Block.Piece.new(Vector2(0,1), color, level, extension),
				Block.Piece.new(Vector2(0,-1), color, level, extension),
				Block.Piece.new(Vector2(-1,1), color, level, extension)
			]
		BlockShape.T:
			pieces = [
				Block.Piece.new(Vector2(0,0), color, level, extension),
				Block.Piece.new(Vector2(-1,0), color, level, extension),
				Block.Piece.new(Vector2(1,0), color, level, extension),
				Block.Piece.new(Vector2(0,1), color, level, extension)
			]
		BlockShape.TINY:
			pieces = [
				Block.Piece.new(Vector2(0,0), color, level, extension),
			]
		BlockShape.SMALL:
			pieces = [
				Block.Piece.new(Vector2(0,0), color, level, extension),
				Block.Piece.new(Vector2(0,-1), color, level, extension)
			]
		BlockShape.ARROW:
			pieces = [
				Block.Piece.new(Vector2(0,0), color, level, extension),
				Block.Piece.new(Vector2(-1,0), color, level, extension),
				Block.Piece.new(Vector2(0,1), color, level, extension)
			]
		BlockShape.CROSS:
			pieces = [
				Block.Piece.new(Vector2(0,0), color, level, extension),
				Block.Piece.new(Vector2(0,-1), color, level, extension),
				Block.Piece.new(Vector2(1,0), color, level, extension),
				Block.Piece.new(Vector2(0,1), color, level, extension),
				Block.Piece.new(Vector2(-1,0), color, level, extension)
			]
		
	var b= Block.new(pieces)
	b.shape=shape;
	b.color=color;
	b.extension=extension
	return b


