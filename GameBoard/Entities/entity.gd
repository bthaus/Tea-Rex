extends GameObject2D
class_name BaseEntity



var map_position: Vector2
@export var tile_id: int=1
@export var collides_with_bullets=false;
@export var processing=false;
@export var moving_types:Array[Monster.MonsterMovingType]=[Monster.MonsterMovingType.GROUND,Monster.MonsterMovingType.AIR]
@export var description:String=""
@export var map_layer:GameboardConstants.MapLayer=GameboardConstants.MapLayer.GROUND_LAYER
@export_range(0,5) var move_weight:float=1
@export var weight_excludes:Array[Monster.MonsterMovingType]=[Monster.MonsterMovingType.AIR]
@export var buildable:bool=false;

func _init(tile_id: int = -1, map_layer: int = -1, map_position: Vector2 = Vector2(0, 0)):
	#self.tile_id = tile_id
	#self.map_layer = map_layer
	self.map_position = map_position
	
func print_data():
	var data=BaseDTO.get_json_from_object(self)
	print(data)
	pass;	

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body
	
func place_on_board(board: TileMap):
	board.set_cell(map_layer, map_position, tile_id, Vector2(0, 0))
	global_position = board.map_to_local(map_position)
	GameState.gameState.register_entity(self)

func remove_from_board(board:TileMap):
	GameState.gameState.unregister_entity(self)
	pass;
func can_move(type:Monster.MonsterMovingType):
	return moving_types.has(type)
		
func get_weight_from_type(type:Monster.MonsterMovingType):
	if weight_excludes.has(type):
		return 1
	return move_weight	
	pass;	
func trigger_minion(monster:Monster):
	
	pass;
func trigger_bullet(bullet:Projectile):
	
	pass;	
func on_cell_left(monster:Monster):
	
	pass;	
func on_battle_phase_started():
	
	pass;
func on_build_phase_started():
	
	pass;
func on_turret_built(turret:Turret):
	
	pass	
func on_destroy():
	
	pass;			
func do(delta):
	
	pass;

	
