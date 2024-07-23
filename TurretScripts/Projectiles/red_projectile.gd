extends Projectile
class_name RedProjectile
var path=[]
func on_creation():
	for cell in associate.referenceCells:
		var glob=associate.collisionReference.getGlobalFromReference(cell)
		path.append(glob)
	pass;
	
func move(delta):
	translateTowardEdge(delta)
	pass;
	
var distance_travelled=0;
var distance_to_next_edge=-1;
var travel_index=0:
	set(value):
		travel_index=value%path.size()
func shoot(target):
	travel_index=0
	super(target)
func translateTowardEdge(delta):
	
	if distance_to_next_edge<=distance_travelled:
		travel_index=travel_index+1;
		distance_travelled=0;
		#if travel_index>path.size()-1:return;
		distance_to_next_edge=global_position.distance_to(path[travel_index])
		
	#if travel_index>path.size()-1:return;
	var direction=(path[travel_index]-global_position).normalized()
	var distance=speed*delta
	distance_travelled=distance_travelled+distance
	translate(direction*distance)
	pass;
