extends BaseDTO
class_name SpawnerDTO

var x: int
var y: int

func _init(x: int, y: int):
	self.x = x
	self.y = y
	
func get_object():
	return Spawner.create(GameState.gameState, Vector2(0,0))
