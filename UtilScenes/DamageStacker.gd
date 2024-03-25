extends Node
class_name DamageStacker
var  hits:int;
var time_elapsed=2;
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_elapsed=delta*time_elapsed-1
	if time_elapsed<=0:
		hits=1;
	pass
	
func hit()->int:
	time_elapsed=2;
	hits=hits+1;
	return hits;
	
