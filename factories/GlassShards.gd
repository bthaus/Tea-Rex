extends BaseEntity
class_name GlassShardsEntity
@export var damage=5
@export var damage_type:GameplayConstants.DamageTypes
@export var hits_types:Array[Monster.MonsterMovingType]=[Monster.MonsterMovingType.GROUND]
func trigger_minion(m:Monster):
	if hits_types.has(m.moving_type):
		m.hit(Turret.Hue.WHITE,damage,damage_type)
	pass;
