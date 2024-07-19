extends TurretCore
class_name MagentaCore


func on_target_found(monster:Monster):
	projectile.shoot(monster)
	pass;
	
func on_target_lost(target):
	projectile.remove()
	pass;

func attack(delta):
	pass;
