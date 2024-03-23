extends Node
class_name Stats;
static var block_size=64;

static var green_range=2*block_size;
static var blue_range=2*block_size;
static var yellow_range=4*block_size;
static var red_range=0.5*block_size;
static var grey_range=2*block_size;

enum TurretColor {GREY=1, GREEN=2, RED=3, YELLOW=4,BLUE=5};


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

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
