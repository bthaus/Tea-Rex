extends GameObject2D
class_name MonsterFactory
static var instance=load("res://monsters/monster_factory.tscn").instantiate()

@export var base_hp:float = 1;
@export var base_damage:float = 5;
@export var base_speed:float = 1.28;

enum MonsterSpeed {Fast=125,Very_Fast=150,Normal=100,Slow=75,Very_Slow=50}
enum MonsterHP {Normal=100,Much=125,Very_Much=150,Little=75,Very_Little=50}
enum MonsterDamage {Normal=5,Much=7,Very_Much=10,Little=3,Very_Little=1}
enum MonsterCooldown {Normal=5,Much=7,Very_Much=10,Little=3,Very_Little=1}
# Called when the node enters the scene tree for the first time.

static func createMonster(type:Monster.MonsterName):
	var searchstring=Monster.MonsterName.keys()[(type)]
	#var searchstring="YETI" #TODO replace with proper monster enum
	var base= instance.get_node(searchstring).duplicate() as MonsterCore
	base.speed=base.speed*instance.base_speed
	base.hp=base.hp*instance.base_hp
	base.damage=base.damage*instance.base_damage
	base.name_id=type
	base.visible=true
	return base
	pass;
