extends TurretBaseMod
class_name HullBaseMod

var base_reload_time=5
var timer=Timer.new()

func get_timeout():
	return base_reload_time/level
func get_type():
	return FreezeTowerDebuff
func get_max_stacks():
	return level	
	
func initialise(turret:TurretCore):
	super(turret)
	timer.wait_time=get_timeout()
	turret.add_child(timer)
	timer.start(get_timeout())
	timer.timeout.connect(add_immunity_stack)
	pass;	

func add_immunity_stack():
	var current_stacks=associate.holder.get_immunity_stacks(get_type())
	if current_stacks < get_max_stacks():
		associate.holder.add_immunity_stack(get_type())
	timer.start(get_timeout())
	pass;
