extends BaseEntity
class_name PlayerBase

func _init(tile_id: int, layer: int, map_position: Vector2):
	super(tile_id, layer, map_position)
func place_on_board(gameboard):
	GameState.gameState.target=self
	return super(gameboard)	

	
