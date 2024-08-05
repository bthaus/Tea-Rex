extends BaseEntity
class_name DamageBoosterEntity
@export var damage_buff:float=25

func on_turret_built(turret:Turret):
	var buff=DamageBuff.new(damage_buff)
	turret.add_buff(buff)
	super(turret)
	pass


