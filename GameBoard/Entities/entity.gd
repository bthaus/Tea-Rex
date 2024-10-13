extends GameObject2D
class_name BaseEntity



var map_position: Vector2
## This ID needs to be set according to the tilesheet. 
@export var tile_id: int=1
## If true, bullets cant pass this entitiy
@export var collides_with_bullets=false;
## If true, the "do" function is called by the gamestate. 
@export var processing=false;
## The movement types of monsters that are allowed on this entitiy
@export var moving_types:Array[Monster.MonsterMovingType]=[Monster.MonsterMovingType.GROUND,Monster.MonsterMovingType.AIR]
## idk ask jojo
@export var map_layer:GameboardConstants.MapLayer=GameboardConstants.MapLayer.GROUND_LAYER
## Determines the speed at which the monsters move on this entity. Lower values mean faster, higher values mean slower
@export_range(0,5) var move_weight:float=1
## Movingtypes in this array agnore the move weight
@export var weight_excludes:Array[Monster.MonsterMovingType]=[Monster.MonsterMovingType.AIR]
## If true, turrets can be built on top of this entitiy. i have no clue what happens then. I assume the entity just stays below the turret?
@export var buildable:bool=false;
#If set to true, the entity will be visible in the level editor and can be placed
@export var usable_in_level_editor:bool=true

func _init(tile_id: int = -1, map_layer: int = -1, map_position: Vector2 = Vector2(0, 0)):
	#self.tile_id = tile_id
	#self.map_layer = map_layer
	self.map_position = map_position
	
func print_data():
	var data=BaseDTO.get_json_from_object(self)
	print(data)
	pass;	


func place_on_board(board: TileMap):
	board.set_cell(map_layer, map_position, tile_id, Vector2(0, 0))
	global_position = board.map_to_local(map_position)
	GameState.gameState.register_entity(self)

func remove_from_board(board:TileMap):
	board.set_cell(map_layer,map_position,-1,Vector2.ZERO)
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

	
