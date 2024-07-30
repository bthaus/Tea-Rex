extends StatusEffect
class_name FrostDebuff
#how much slow can be applied in total
var max_slow
var change=0


func _init(lifetime,associate,str,max):
	self.max_slow=max
	super(lifetime,associate,str)
	pass;
func get_name():
	return "frost"
func on_initial_application():
	affected=affected as Monster
	change=affected.speed
	affected.speed-=max_slow
	change-=affected.speed
	super()
	pass;
func on_removal():
	affected=affected as Monster
	affected.speed+=change
	super()
	pass;
