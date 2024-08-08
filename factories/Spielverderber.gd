extends BaseEntity
class_name SpielverderberEntity
var no_places=[]
func place_on_board(board: TileMap):
	super(board)
	var vecs=[]
	
	GameState.gameState.collisionReference.getNeighbours(get_global(),vecs)
	for v in vecs:
		var dto=EntityDTO.new(8,v.x,v.y)
		var instance=EntityFactory.create(dto) 
		instance.place_on_board(board)
		no_places.push_back(instance)
		
	
	pass;
func remove_from_board(board:TileMap):
	for p in no_places:
		p.remove_from_board(board)
	super(board)	
	pass;
