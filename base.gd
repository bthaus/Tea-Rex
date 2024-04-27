extends Sprite2D
class_name Base
var level=1;
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func setLevel(lvl:int):
	var children=get_children()
	level=lvl;
	for i in range(lvl):
		if i<children.size():
			children[i].visible=true;
	pass;
	
func getBarrels():
	var children=get_children()
	var ret=[]
	for i in range(level):
		if i<children.size():
			ret.append(children[i])
	return ret;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
