extends Projectile
class_name RedProjectile

func get_global():
	return $orb.global_position	
	
func move(delta):
	rotate(delta)
	pass;

func shoot(target):
	super(target)

