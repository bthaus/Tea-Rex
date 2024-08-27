extends BaseEntity
class_name PlayerBase
var color=2
var _astar_id

func _init(tile_id: int, map_layer: GameboardConstants.MapLayer, map_position: Vector2,c):
	color=c
	super(tile_id, map_layer, map_position)
	self.tile_id = tile_id
	self.map_layer = map_layer
	
func place_on_board(gameboard):
	GameState.gameState.add_target(self)
	return super(gameboard)	

	
