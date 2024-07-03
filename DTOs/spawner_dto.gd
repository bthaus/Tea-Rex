extends EntityDTO
class_name SpawnerDTO

func _init(tile_id: int = -1, x: int = -1, y: int = -1):
	super(tile_id, x, y)
	
func get_object():
	return Spawner.create(GameState.gameState, Vector2(0,0))
