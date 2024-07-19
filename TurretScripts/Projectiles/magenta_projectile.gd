extends Projectile
class_name MagentaProjectile

var origin:Node2D
var line:Line2D
var buildup:float:
	set(val):
		buildup=clamp(val,0,1)
func on_creation():
	line=Line2D.new()
	add_child(line)
	origin=associate
	pass;	


func shoot(target):
	super(target)
	global_rotation=0
	pass;
func move(delta):
	if origin==null or !is_instance_valid(origin):remove();return
	buildup=buildup+delta
	line.clear_points()
	line.add_point(origin.global_position)
	var direction = (target.global_position - origin.global_position)*buildup
	line.add_point(direction)
	line.global_position=Vector2(0,0)
	cell_position=direction
	pass;
