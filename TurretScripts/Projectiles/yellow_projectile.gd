extends Projectile

func hitEnemy(enemy: Monster,from_turret=false):
	if target==null or !is_instance_valid(target):
		super(enemy)
		return;
	if enemy==target:
		super(enemy)	
	pass;
func move(delta):
	if target== null or not is_instance_valid(target):
		super(delta)
		return;
	
	direction = (target.global_position - self.global_position).normalized();
	global_rotation = direction.angle() + PI / 2.0
	super(delta)
	pass;
