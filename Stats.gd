extends Node
class_name Stats;
static var block_size=64;

static var base_range=10;
static var green_range=2*base_range;
static var blue_range=2*base_range;
static var yellow_range=4*base_range;
static var red_range=1*base_range;
static var grey_range=2*base_range;


static var base_cooldown=1;
static var green_cooldown=base_cooldown*1;
static var blue_cooldown=base_cooldown*2;
static var yellow_cooldown=base_cooldown*3;
static var grey_cooldown=base_cooldown*1;
static var red_cooldown=base_cooldown*1;

static var base_damage=10;
static var green_damage=base_damage*1;
static var blue_damage=base_damage*2;
static var yellow_damage=base_damage*3;
static var grey_damage=base_damage*1;
static var red_damage=base_damage*1;


enum TurretColor {GREY=1, GREEN=2, RED=3, YELLOW=4,BLUE=5};


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
static func getStringFromEnum(type:TurretColor):
	match type:
		1: return "GREY";
		2: return "GREEN";
		3:return "RED";
		4: return "YELLOW";
		5: return "BLUE";
	pass
	
static func getCooldown(type:TurretColor):
	match type:
		1: return grey_cooldown;
		2: return green_cooldown;
		3:return red_cooldown;
		4: return yellow_cooldown;
		5: return blue_cooldown;
	pass

static func getDamage(type:TurretColor):
	match type:
		1: return grey_damage;
		2: return green_damage;
		3:return red_damage;
		4: return yellow_damage;
		5: return blue_damage;
	pass

static func getRange(type:TurretColor):
	match type:
		1: return grey_range;
		2: return green_range;
		3:return red_range;
		4: return yellow_range;
		5: return blue_range;
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
