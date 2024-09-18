extends BaseEntity
class_name BarrelEntity
@export var explodes_with:Array[GameplayConstants.DamageTypes]=[]
@export var damage_type:GameplayConstants.DamageTypes
@export var damage:float=100
@export var health:float=5000:
	set(value):
		health=value
		if health<0:
			remove_from_board(GameState.board)
func trigger_bullet(p:Projectile):
	var types=p.get_damage_types()
	for e in explodes_with:
		if types.has(e):
			explode()
			break;
	health-=p.damage
			
	pass;

func explode():
	Explosion.create(damage_type,damage,global_position,self)
	remove_from_board(GameState.board)
	GameState.gameState.recalculate_minion_paths()
	pass;
