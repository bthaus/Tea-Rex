extends BaseEntity
class_name ModProduce
@export var oneshot=true

var associate

func place_on_board(board: TileMap):
	global_position = board.map_to_local(map_position)
	GameState.gameState.register_entity(self)
func trigger_minion(monster:Monster):
	if oneshot:
		remove_from_board(GameState.board)
	super(monster)	
	pass;
func remove_from_board(board:TileMap):
	associate.cache.push_back(self)
	super(board)
	pass;
func get_instance():
	pass	
func can_move(type:Monster.MonsterMovingType):
	return true
func get_weight_from_type(type:Monster.MonsterMovingType):
	return 1
	pass;		
