extends PermanentStatusEffect
class_name CooldownBuff

func on_initial_application():
	associate.cooldown*=strength
	pass;
	
func get_name():
	return Name.COOLDOWN		
