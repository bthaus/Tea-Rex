extends StatusEffect
class_name PoisonDebuff
#how much slow can be applied in total
var damage_per_tick
var propagation_time
const color=Turret.Hue.GREEN



func _init(lifetime,associate,str,tick_damage,propagation_time):
	super(lifetime,associate,str)
	self.propagation_time=propagation_time
	self.damage_per_tick=tick_damage

	pass;
func get_name():
	return Name.POISONED
	
func apply_effect(delta):
	var killed= affected.hit(color, damage_per_tick*get_str())
	if killed:associate.on_target_killed(affected)
	pass;
func propagate():
	if !util.valid(affected):return
	var ms=GameState.gameState.collisionReference.getMinionsAroundPosition(affected.global_position)
	for m in ms:
		var poison=PoisonDebuff.new(default_lifetime,
		associate,get_str(),damage_per_tick,propagation_time)
		poison.register(affected)
		
	pass;	
func get_container():
	return poison_container.new(affected)
	pass;	

class poison_container extends status_effect_container:
	var time_since_last_propagation=0
	func trigger(delta):
		super(delta)
		if strongest_status_effect==null:return
		time_since_last_propagation+=delta
		if time_since_last_propagation>strongest_status_effect.propagation_time:
			strongest_status_effect.propagate()
			time_since_last_propagation-=strongest_status_effect.propagation_time
		pass;
