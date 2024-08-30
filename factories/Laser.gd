extends BaseEntity
class_name LaserEntity
@export var shoot_min_time:float=1
@export var shoot_max_time:float=10
@export var direction:Direction=Direction.LEFT
@export var damage=50
@export var speed=150
var projectile_precision=25
var bullets=[]
enum Direction{LEFT,RIGHT,UP,DOWN}
var angles={
	LEFT=Vector2(-1,0),
	RIGHT=Vector2(1,0),
	UP=Vector2(0,-1),
	DOWN=Vector2(0,1)
}
var target
func _ready():
	bullets.append(Projectile.create(Turret.Hue.MAGENTA,damage,speed,self))
	get_tree().create_timer(get_random_time()).timeout.connect(shoot_laser)
	pass;

func get_random_time():
	return randf_range(shoot_min_time,shoot_max_time)
func on_projectile_removed(bullet):
	
	pass;
func on_hit(enemy,damage,type,killed,bt):
	pass;
func start_cooldown():
	pass;		
func on_fly(b):pass		
func shoot_laser():
	var projectile=bullets.front()
	projectile.shoot(self)
	projectile.direction=angles[Direction.keys()[direction]]
	pass;
