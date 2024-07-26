extends Debuff
class_name FrostDebuff
#how much slow can be applied in total
var max_slow


func _init(lifetime,str,max,step):
	self.max_slow=max
	self.slow_step=step
	super(lifetime,str)
	pass;
func get_name():
	return "frost"
func on_initial_application():
	affected=affected as Monster
	affected.speed-=max_slow
	super()
	pass;
func on_removal():
	affected=affected as Monster
	affected.speed+=max_slow
	super()
	pass;
