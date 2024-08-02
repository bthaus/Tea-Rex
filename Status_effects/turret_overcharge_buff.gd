extends StatusEffect
class_name OverchargeBuff
var factor

func _init(str,associate,factor,lifetime=GameplayConstants.DEBUFF_STANDART_LIFETIME):
	super(str,associate,lifetime)
	self.factor=1-(factor/100)*get_str()
	
func get_name():
	return Name.OVERCHARGED
	
func on_initial_application():
	affected=affected as TurretCore
	affected.cooldownfactor*=factor*get_str()
	affected.reset_cooldown()
	pass;
func on_removal():
	affected=affected as TurretCore
	affected.cooldownfactor/=factor*get_str()
	pass;	
