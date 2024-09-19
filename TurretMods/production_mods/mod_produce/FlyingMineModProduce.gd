extends ModProduce
class_name FlyingMineModProduce
@export var damage=100
func trigger_minion(monster:Monster):
	if !monster.core.movable_cells.has(Monster.MonsterMovingType.AIR):return
	Explosion.create(GameplayConstants.DamageTypes.EXPLOSION,damage*associate.lvl,get_global(),associate.associate)
	super(monster)
