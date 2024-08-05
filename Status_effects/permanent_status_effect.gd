extends StatusEffect
class_name PermanentStatusEffect

func _init(str=1,associate=null):
	super(str,associate)
	
func on_tick(delta):
	time_slice_time+=delta
	if time_slice_time>time_slice_duration:
		time_slice_time-=time_slice_duration
		apply_effect(delta)
	pass;
