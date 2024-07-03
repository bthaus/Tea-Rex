extends GameObject2D
class_name DamageStacker
var  hits:float=1;
var time_elapsed=2;
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_elapsed=time_elapsed-1*delta
	if time_elapsed<=0:
		queue_free()
	pass
	
func hit()->float:
	time_elapsed=2;
	hits=hits+Stats.red_laser_damage_stack;
	return hits;
	
