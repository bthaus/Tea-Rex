extends StatusEffect
class_name FreezeTowerDebuff
var old_val
func get_name():
	return Name.FROZEN_TOWER
func on_initial_application():
	affected=affected
	old_val=affected.base.action_speed
	affected.base.action_speed-=1*effectiveness
	old_val=old_val-affected.base.action_speed
	super()
	pass;
func on_removal():
	affected=affected
	affected.base.action_speed+=old_val
	super()
	pass;
