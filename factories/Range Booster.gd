extends BaseEntity
class_name RangeBoosterEntity
@export var range_buff:int=2

func on_turret_built(turret:Turret):
	var buff=RangeBuff.new(range_buff)
	turret.add_buff(buff)
	super(turret)
	pass
