extends StatusEffect
class_name FireDebuff
#how much slow can be applied in total
var damage_per_tick
const color=Turret.Hue.RED



func _init(lifetime=GameplayConstants.DEBUFF_STANDART_LIFETIME,associate=null,str=1,tick_damage=2):
	super(lifetime,associate,str)
	self.damage_per_tick=tick_damage
	pass;
func get_name():
	return Name.BURNING
	
func apply_effect(delta):
	var killed= affected.hit(color, damage_per_tick*get_str())
	if !util.valid(associate):return
	if killed:associate.on_target_killed(affected.holder)
	pass;	
