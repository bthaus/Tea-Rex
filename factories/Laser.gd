extends BaseEntity
class_name LaserEntity
@export var shoot_min_time:float=1
@export var shoot_max_time:float=10
@export var direction:Direction=Direction.LEFT

enum Direction{LEFT,RIGHT,UP,DOWN}

func _ready():
	
	get_tree().create_timer(get_random_time()).timeout.connect(shoot_laser)
	pass;

func get_random_time():
	return randf_range(shoot_min_time,shoot_max_time)
	
func shoot_laser():
	
	pass;
