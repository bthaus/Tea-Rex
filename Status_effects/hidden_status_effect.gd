extends PermanentStatusEffect
class_name HiddenStatusEffect
func _init():
	super(1,null)
	pass;
func get_name():
	return Name.HIDDEN	
func on_initial_application():
	affected.change_status_effect()
	super()
	pass;
