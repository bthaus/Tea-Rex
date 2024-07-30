extends StatusEffect
class_name FireDebuff
#how much slow can be applied in total
var damage_per_tick
const color=Turret.Hue.RED



func _init(lifetime,associate,str,tick_damage):
	self.damage_per_tick=tick_damage
	super(lifetime,associate,str)
	pass;
func get_name():
	return "fire"
	
func apply_effect(delta):
	print("firing")
	affected.hit(color, damage_per_tick)
	pass;	
