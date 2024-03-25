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
	$Area2D/detectionshape.scale=Vector2(mult,mult);
	pass;
func _process(delta):
	pass

func getFirstEnemy():
	
	if(enemiesInRange.size()==0):
		return null;
	return enemiesInRange[0];
func _on_area_2d_area_entered(area):
	
	if(area.get_parent() is Monster):
		enemiesInRange.push_back(area.get_parent());
	
	pass # Replace with function body.


func _on_area_2d_area_exited(area):
	
	if(area.get_parent() is Monster):
		var index=enemiesInRange.find(area.get_parent());
		enemiesInRange.remove_at(index);
	
	
	pass # Replace with function body.
