extends BaseEntity
class_name ForestEntity
var burning=false
@export var burning_time:float=4
func trigger_projectile(p:Projectile):
	if burning:return
	if p.get_damage_types().has(GameplayConstants.DamageTypes.FIRE):
		start_fire()
	pass;

func trigger_minion(m:Monster):
	if not burning:return
	var debuff=FireDebuff.new()
	debuff.register(m)
	pass;

var fire
func start_fire():
	burning=true
	fire=load("res://effects/cell_fire.tscn").instantiate()
	GameState.gameState.add_child(fire)
	get_tree().create_timer(burning_time).timeout.connect(remove)
	pass;

func remove():
	GameState.gameState.unregister_entity(self)
	fire.remove()
	pass;	
