extends BaseEntity
class_name ForestEntity
var burning=false
@export var burning_time:float=4
func trigger_bullet(p:Projectile):
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
var fire_cell
func start_fire():
	burning=true
	$cell_fire.emitting=true
	GameState.gameState.add_child(fire)
	fire_cell=CellFireEntity.new(FireDebuff.new(),map_position,burning_time)
	get_tree().create_timer(burning_time).timeout.connect(remove_from_board)
	pass;

func remove_from_board(map=GameState.board):
	$cell_fire.emitting=false
	
	fire_cell.remove()
	super(map)
	GameState.gameState.recalculate_minion_paths()
	pass;	
