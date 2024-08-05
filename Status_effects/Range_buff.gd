extends PermanentStatusEffect
class_name RangeBuff

func on_initial_application():
	associate=associate as TurretCore
	associate.range=strength
	associate.setupCollision(true)
	pass;
	
	
func get_name():
	return Name.RANGE	
