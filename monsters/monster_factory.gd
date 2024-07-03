extends GameObject2D
class_name MonsterFactory
static var instance=load("res://monsters/monster_factory.tscn").instantiate()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

static func createMonster(type:Stats.Monstertype):
	var searchstring=Stats.Monstertype.keys()[(type)]
	var base= instance.get_node(searchstring).duplicate() as MonsterAppearance
	return base
	pass;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
