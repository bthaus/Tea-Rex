extends Projectile
class_name RedProjectile
var rotation_direction=CLOCKWISE
func on_creation():
	#z_index=2
	super()
	pass;

func get_global():
	return $orb.global_position	
func add_emitter(emitter):
	emitters.append(emitter)
	$orb.add_child(emitter)
	pass;	
	
func toggle_emitter(b):
	
	pass;	
func move(delta):
	rotate(delta)
	pass;

func remove():
	pass;
func duplicate_and_shoot(angle,origin=null)->Projectile:	
	if origin==associate:
		return associate.shoot(target)
	return null	
	pass;	
func destroy():
	super.remove()
