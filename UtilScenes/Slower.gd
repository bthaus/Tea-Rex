extends GameObject2D

class_name Slower
var duration;
var originalDuration;
var factor;
var monster
var restore;
var ID;
var reapplies=1;




# Called when the node enters the scene tree for the first time.
func _ready():
	process_mode=Node.PROCESS_MODE_ALWAYS
	apply()
	pass # Replace with function body.
func apply():
	monster=get_parent() as Monster
	restore=monster.speedfactor
	monster.speedfactor=monster.speedfactor*factor
	#monster.resetTween()
	pass;
static func create(duration,factor)->Slower:
	var retval=Slower.new();
	retval.originalDuration=duration;
	retval.duration=duration;
	retval.factor=factor;
	return retval;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func remove():
	for i in reapplies:
		monster.speedfactor=monster.speedfactor/factor;
	#monster.resetTween()
	queue_free()
	pass;
func _process(delta):
	duration=duration-1*delta;
	if duration<=0&&duration>-1000:
		remove()
	pass
func reapply():
	duration=originalDuration
	if pow(factor,reapplies)<0.1:
		return;
	reapplies=reapplies+1;
	
	apply()
	pass;
