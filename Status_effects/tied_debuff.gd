extends StatusEffect
class_name TiedDebuff

var old_val
func get_name():
	return Name.TIED
func on_initial_application():
	affected=affected
	old_val=affected.speed
	affected.speed-=affected.speed*effectiveness
	old_val=old_val-affected.speed
	super()
	pass;
func on_removal():
	affected=affected
	affected.speed+=old_val
	super()
	pass;
