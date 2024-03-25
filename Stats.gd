extends Node
class_name Stats;
static var block_size=64;

static var base_range=10;
static var green_range=2*base_range;
static var blue_range=2*base_range;
static var yellow_range=10*base_range;
static var red_range=0.2*base_range;
static var grey_range=2*base_range;

static var red_laser_range=1*base_range;
static var blue_laser_range=3*base_range;

static var base_missile_speed=1000;
static var green_missile_speed=1*base_missile_speed;
static var blue_missile_speed=2*base_missile_speed;
static var yellow_missile_speed=10*base_missile_speed;
static var red_missile_speed=1*base_missile_speed;
static var grey_missile_speed=2*base_missile_speed;

static var blue_laser_missile_speed=base_missile_speed*4;
static var red_laser_missile_speed=base_missile_speed*1;


static var base_cooldown=1;
static var green_cooldown=base_cooldown*3;
static var blue_cooldown=base_cooldown*1;
static var yellow_cooldown=base_cooldown*2;
static var grey_cooldown=base_cooldown*1;
static var red_cooldown=base_cooldown*0.3;

static var red_laser_cooldown=base_cooldown*0.005;
static var blue_laser_cooldown=base_cooldown*0.3;

static var base_damage=5;
static var green_damage=base_damage*1;
static var blue_damage=base_damage*2;
static var yellow_damage=base_damage*3;
static var grey_damage=base_damage*1;
static var red_damage=base_damage*1;

static var red_laser_damage=base_damage*0.05;
static var blue_laser_damage=base_damage*1;

static var base_penetrations=1;
static var green_penetrations=base_penetrations*1;
static var blue_penetrations=base_penetrations*1;
static var yellow_penetrations=base_penetrations*1;
static var grey_penetrations=base_penetrations*1;
static var red_penetrations=base_penetrations*-1000000;

static var red_laser_penetrations=base_penetrations*1;
static var blue_laser_penetrations=base_penetrations*5;

static var green_explosion_range=0.5;
static var red_laser_damage_stack=0.05;


static var enemyHP=500;

enum TurretColor {GREY=1, GREEN=2, RED=3, YELLOW=4,BLUE=5};
enum TurretExtension {DEFAULT=1,REDLASER=2, BLUELASER=3, YELLOWCATAPULT=4, GREENPOISON=5};

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
static func getStringFromEnum(type:TurretColor):
	
	match type:
		1: return "GREY";
		2: return "GREEN";
		3: return "RED";
		4: return "YELLOW";
		5: return "BLUE"
	pass
static func getStringFromEnumLowercase(type:TurretColor):
	
	match type:
		1: return "grey";
		2: return "green";
		3: return "red";
		4: return "yellow";
		5: return "blue"
	pass
static func getStringFromEnumExtension(type:TurretExtension):
	
	match type:
		1: return ""
		2: return "LASER"
		3: return "LASER"
	
	return "";
static func getStringFromEnumExtensionLowercase(type:TurretExtension):
	match type:
		1: return ""
		2: return "laser"
		3: return "laser"
	
	return "";

static func getProperty(type:TurretColor,extension:TurretExtension,property:String):
	var color=getStringFromEnumLowercase(type);
	var ext=getStringFromEnumExtensionLowercase(extension);
	var temp;
	if extension==TurretExtension.DEFAULT:
		temp = Stats.new().get(color+"_"+property);
	else:
		temp = Stats.new().get(color+"_"+ext+"_"+property);
	return temp;

static func getCooldown(type:TurretColor,extension:TurretExtension):
	
	return getProperty(type,extension,"cooldown");

static func getDamage(type:TurretColor,extension:TurretExtension):
	return getProperty(type,extension,"damage");


static func getMissileSpeed(type:TurretColor,extension:TurretExtension):
	return getProperty(type,extension,"missile_speed");

static func getOneshotType(type:TurretColor,extension:TurretExtension):
	return getProperty(type,extension,"penetrations");

static func getRange(type:TurretColor,extension:TurretExtension):
	return getProperty(type,extension,"range")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
