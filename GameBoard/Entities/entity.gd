extends GameObject2D
class_name BaseEntity

var tile_id: int
var map_layer: int
var map_position: Vector2
var collides_with_bullets=false;
func _init(tile_id: int = -1, map_layer: int = -1, map_position: Vector2 = Vector2(0, 0)):
	self.tile_id = tile_id
	self.map_layer = map_layer
	self.map_position = map_position
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body
	
func place_on_board(board: TileMap):
	GameState.gameState.collisionReference.register_entity(self)
	board.set_cell(map_layer, map_position, tile_id, Vector2(0, 0))
	global_position = board.map_to_local(map_position)

func trigger_minion(monster:Monster):
	
	pass;
func trigger_bullet(bullet:Projectile):
	
	pass;	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
