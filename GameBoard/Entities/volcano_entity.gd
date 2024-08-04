extends BaseEntity
class_name BurningVolcanoEntity

@export var explosion_time_min:float=4
@export var explosion_time_max:float=12

@export var fire_damage:float=10
@export var fire_duration:float=4

var explosion_timer=0
var running=false
func on_battle_phase_started():
	running=true
	set_timer()
	pass;
func set_timer():
	explosion_timer=randf_range(explosion_time_min,explosion_time_max)
	pass;	
func on_build_phase_started():
	running=false
	pass;	
func do(delta):
	if not running:return
	explosion_timer-=delta
	if explosion_timer<0:
		trigger_volcano()
		set_timer()
		
	
	pass;

func trigger_volcano():
	
	pass;
