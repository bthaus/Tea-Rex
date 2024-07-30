extends StatusEffect
class_name OverchargeBuff
var factor

func _init(str,associate,factor,lifetime=GameplayConstants.DEBUFF_STANDART_LIFETIME):
	self.factor=1-(factor/100)
	super(str,associate,lifetime)

func on_initial_application():
	affected=affected as TurretCore
	affected.cooldownfactor*=factor
	affected.reset_cooldown()
	pass;
func on_removal():
	affected=affected as TurretCore
	affected.cooldownfactor/=factor
	pass;	
