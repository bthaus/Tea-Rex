extends BaseEntity
class_name CooldownBoosterEntity
@export var cooldown_buff:float=0.75

func on_turret_built(turret:Turret):
	var buff=CooldownBuff.new(cooldown_buff)
	turret.add_buff(buff)
	super(turret)
	pass


