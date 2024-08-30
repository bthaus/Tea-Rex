extends ModProduce
class_name MineModProduce
@export var damage=100
func _ready():
	print("hi??")
func trigger_minion(monster:Monster):
	if !monster.core.movable_cells.has(Monster.MonsterMovingType.GROUND):return
	Explosion.create(GameplayConstants.DamageTypes.EXPLOSION,damage*associate.level,get_global(),associate.associate)
	super(monster)

