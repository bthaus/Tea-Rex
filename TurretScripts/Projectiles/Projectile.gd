extends Node2D

var shot=false;
var damage=Stats.getDamage(Stats.TurretColor.RED);
var direction:Vector2;
# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.

func shoot(target,damage):
	$AudioStreamPlayer2D.play();
	self.damage=damage;
	direction=(target.global_position-self.global_position).normalized();
	global_rotation=direction.angle() + PI / 2.0
	shot=true;
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if shot:
		translate(direction*delta*1000);
	pass


func _on_area_2d_area_entered(area):
	if(area.get_parent().name!="Monster"):
		return;
	area.get_parent().hit(Stats.TurretColor.RED,self.damage);
	queue_free();
	
	pass # Replace with function body.
