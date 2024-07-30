extends StatusEffect
class_name PoisonDebuff
#how much slow can be applied in total
var damage_per_tick
var propagation_time
const color=Turret.Hue.GREEN



func _init(lifetime,associate,str,tick_damage):
	self.damage_per_tick=tick_damage
	super(lifetime,associate,str)
	pass;
func get_name():
	return "poison"
	
func apply_effect(delta):
	var killed= affected.hit(color, damage_per_tick)
	if killed:associate.on_target_killed(affected)
	pass;
func get_container():
	
	pass;		
