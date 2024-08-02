extends GameObject2D
class_name MonsterFactory
static var instance=load("res://monsters/monster_factory.tscn").instantiate()

@export var base_hp:float = 100;
@export var base_damage:float = 5;
@export var base_speed:float = 128;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

static func createMonster(type:Monster.MonsterName):
	#var searchstring=Monster.Monstertype.keys()[(type)]
	var searchstring="SNOWMAN" #TODO replace with proper monster enum
	var base= instance.get_node(searchstring).duplicate() as MonsterCore
	base.speed=base.speed*instance.base_speed
	base.hp=base.hp*instance.base_hp
	base.damage=base.damage*instance.base_damage
	return base
	pass;
