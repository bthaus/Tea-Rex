extends PermanentStatusEffect
class_name CamouflageBuff
var change
func on_initial_application():
	change=affected.dodge_chance
	affected.dodge_chance+=strength
	change-=affected.dodge_chance
	pass;
func on_removal():
	affected.dodge_chance+=change
	pass;

func get_name():
	return Name.CAMOUFLAGE	
