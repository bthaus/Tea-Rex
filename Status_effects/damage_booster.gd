extends PermanentStatusEffect
class_name DamageBuff

func on_initial_application():
	associate.damage_factor=strength
	pass;
	
	
func get_name():
	return Name.DAMAGE	
