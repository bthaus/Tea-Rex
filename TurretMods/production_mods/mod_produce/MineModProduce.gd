extends ModProduce
class_name MineModProduce
@export var damage=100
func trigger_minion(monster:Monster):
	Explosion.create(GameplayConstants.DamageTypes.EXPLOSION,damage,get_global(),associate)
	

