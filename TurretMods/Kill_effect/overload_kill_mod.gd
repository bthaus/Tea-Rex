extends TurretBaseMod
class_name OverchargeKillMod
#func _init(str,associate,factor,lifetime=GameplayConstants.DEBUFF_STANDART_LIFETIME):

func on_kill(m:Monster):
	var charge=OverchargeBuff.new(level,associate,
	OVERCHARGE_COOLDOWN_REDUCTION*pow(OVERCHARGE_SCALING,level),
	OVERCHARGE_BUFF_DURATION*pow(OVERCHARGE_SCALING,level))
	charge.register(associate)
	super(m)
	pass;
