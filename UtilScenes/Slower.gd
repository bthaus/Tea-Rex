extends Node

class_name Slower
var duration;
var factor;
var monster
var restore;

# Called when the node enters the scene tree for the first time.
func _ready():
	monster=get_parent() as Monster
	restore=monster.speedfactor
	monster.speedfactor=factor
	pass # Replace with function body.

static func create(duration,factor)->Slower:
	var retval=Slower.new();
	retval.duration=duration;
	retval.factor=factor;
	return retval;
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta):
	duration=duration-1*delta;
	if duration<=0:
		monster.speedfactor=restore;
		queue_free()
	pass

