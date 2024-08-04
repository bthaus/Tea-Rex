extends BaseEntity
class_name CellFireEntity
var debuff:FireDebuff
var life_time=1
func _init(fire_debuff,map_pos,lifetime):
	debuff=fire_debuff
	life_time=lifetime
	super(1,1,map_pos)
	pass;
func place_on_board(board:TileMap=null):
	global_position = GameState.board.map_to_local(map_position)
	GameState.gameState.register_entity(self)
	pass;
func trigger_minion(m:Monster):
	
	var d=FireDebuff.new(debuff.lifetime,debuff.associate,debuff.strength,debuff.damage_per_tick)
	d.register(m)
	pass;
func remove():
	GameState.gameState.unregister_entity(self)
	queue_free()
	pass;	
