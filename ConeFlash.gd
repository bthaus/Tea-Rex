extends PointLight2D
class_name ConeFlash
var duration;
static func flash(global_position, duration,root,angle,size=1):
	var temp=load("res://UtilScenes/cone_flash.tscn").instantiate()as ConeFlash;
	temp.duration=duration;
	temp.apply_scale(Vector2(size,size));
	temp.global_rotation=angle;
	root.add_child(temp);
	temp.global_position=global_position;
	pass
# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	duration=duration-1*delta;
	energy=energy-1*delta;
	if duration <=0:
		queue_free();
	pass
