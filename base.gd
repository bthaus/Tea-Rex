extends Sprite2D
class_name Base
var level = 1;
var barrels = []
# Called when the node enters the scene tree for the first time.
func _ready():
	barrels = get_children()
	for b in barrels:
		remove_child(b)
	pass # Replace with function body.

func setLevel(lvl: int):
	var children = barrels
	level = lvl;
	for i in range(lvl):
		if i < children.size():
			add_child(children[i])
			children[i].visible = true;

	pass ;
	
func getBarrels():
	var children = get_children()
	var ret = []
	for i in range(level):
		if i < children.size():
			ret.append(children[i])
	return ret;
# Called every frame. 'delta' is the elapsed time since the previous frame.
