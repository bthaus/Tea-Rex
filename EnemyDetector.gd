extends Node2D
class_name EnemyDetector
@export var rangeMult=1;

@export var enemiesInRange=[];



# Called when the node enters the scene tree for the first time.
func _ready():
	setRange(rangeMult)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.

func setRange(mult):
	$Area2D/detectionshape.apply_scale(Vector2(mult,mult));
	pass;
func _process(delta):
	pass


func _on_area_2d_area_entered(area):
	if(area.get_parent().name!="Monster"):
		return;
	enemiesInRange.push_back(area.get_parent());
	print("enemy added at index");
	pass # Replace with function body.


func _on_area_2d_area_exited(area):
	if(area.get_parent().name!="Monster"):
		return;
	var index=enemiesInRange.find(area.get_parent());
	enemiesInRange.remove_at(index);
	
	pass # Replace with function body.
