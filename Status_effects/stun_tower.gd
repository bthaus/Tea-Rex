extends StatusEffect
class_name StunTowerDebuff
var old_val
func get_name():
	return Name.STUN_TOWER
func on_initial_application():
	affected=affected
	affected.base.functional=false
	super()
	pass;
func on_removal():
	affected=affected
	affected.base.functional=true
	super()
	pass;
