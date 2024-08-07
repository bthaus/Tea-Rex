extends BaseEntity
class_name SpielverderberEntity

func place_on_board(board: TileMap):
	super(board)
	var vecs=[]
	GameState.gameState.collisionReference.getNeighbours(get_global(),vecs)
	for v in vecs:
		GameState.collisionReference.register_entity_at_position(self,board.map_to_local(v))

	
	pass;
func remove_from_board(board:TileMap):
	var vecs=[]
	GameState.gameState.collisionReference.getNeighbours(get_global(),vecs)
	for v in vecs:
		GameState.collisionReference.remove_entity_from_position(self,board.map_to_local(v))

	pass;
