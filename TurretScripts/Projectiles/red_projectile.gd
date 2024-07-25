extends Projectile
class_name RedProjectile
var rotation_direction=CLOCKWISE
var is_duplicate=false;
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
	penetrations=1
	if not is_duplicate:
		rotate(delta)
		direction = (get_global() - associate.get_global()).normalized()
	else:
		super(delta)	
	pass;

func remove():
	pass;
func _get_duplicate():
	var t= Projectile.factory.duplicate_bullet(self)
	t.get_child(0).scale=Vector2(0.25,0.25)
	t.get_child(0).position=Vector2(0,0)
		
	return t
func duplicate_and_shoot(angle,origin=null)->Projectile:	
	var temp=super(angle,self)
	temp.is_duplicate=true
	get_tree().create_timer(0.5).timeout.connect(temp.destroy)
	return temp
	pass;
	

			
func destroy():
	is_duplicate=false;
	super.remove()
