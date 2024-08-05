extends StatusEffect
class_name HiddenStatusEffect
func _init():
	super(1,null,99999)
	pass;
func get_name():
	return Name.HIDDEN	
func on_initial_application():
	affected.change_status_effect()
	super()
	pass;
