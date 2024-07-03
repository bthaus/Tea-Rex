extends GameObject2D
class_name LevelEditorBoardHandler

var board: TileMap

var spawner_positions: PackedVector2Array = [] #Holds all the spawners on the board. Index indicates which spawner is which.

signal spawner_added
signal spawner_removed

func _init(board: TileMap):
	self.board = board

func get_tile_type_by_id(id: int):
	if id == -1: return null
	var atlas: TileSetAtlasSource = board.tile_set.get_source(id)
	var data = atlas.get_tile_data(Vector2(0,0), 0)
	if data == null: return null
	return data.get_custom_data("type").to_upper()
	
func get_tile_type(layer: int, map_position: Vector2):
	var data = board.get_cell_tile_data(layer, map_position)
	if data == null: return null
	return data.get_custom_data("type").to_upper()

func set_cell(id: int, map_position: Vector2):
	var board_type = get_tile_type(GameboardConstants.BLOCK_LAYER, map_position)
	var is_spawner_below = board_type != null and board_type == GameboardConstants.SPAWNER_TYPE
	var type = get_tile_type_by_id(id)
	if is_spawner_below and type != GameboardConstants.SPAWNER_TYPE: #If there is a spawner below, remove it (unless the holding piece is a spawner)
		var i = _get_spawner_idx_at(map_position)
		spawner_positions.remove_at(i)
		spawner_removed.emit(i)
			
	match(type):
		GameboardConstants.GROUND_TYPE:
			board.set_cell(GameboardConstants.GROUND_LAYER, map_position, id, Vector2(0,0))
			board.set_cell(GameboardConstants.BLOCK_LAYER, map_position, -1, Vector2(0,0))
			return
		GameboardConstants.SPAWNER_TYPE:
			if is_spawner_below: return #There is already a spawner below, ignore it
			spawner_positions.append(map_position)
			spawner_added.emit()
	
	board.set_cell(GameboardConstants.BLOCK_LAYER, map_position, id, Vector2(0,0))
	board.set_cell(GameboardConstants.GROUND_LAYER, map_position, -1, Vector2(0,0))
	
func clear_cell(map_position: Vector2):
	var board_type = get_tile_type(GameboardConstants.BLOCK_LAYER, map_position)
	if board_type != null and board_type == GameboardConstants.SPAWNER_TYPE: #There was a spawner below
			var i = _get_spawner_idx_at(map_position)
			spawner_positions.remove_at(i)
			spawner_removed.emit(i)
	
	board.set_cell(GameboardConstants.BLOCK_LAYER, map_position, -1, Vector2(0,0))
	board.set_cell(GameboardConstants.GROUND_LAYER, map_position, -1, Vector2(0,0))

func _get_spawner_idx_at(map_position: Vector2) -> int:
	for i in spawner_positions.size():
		if spawner_positions[i] == map_position:
			return i
	return -1

func save_board(monster_waves,map_name):
	var entities:Array[BaseDTO] = []
	
	for pos in board.get_used_cells(GameboardConstants.BLOCK_LAYER):
		var id = board.get_cell_source_id(GameboardConstants.BLOCK_LAYER, pos)
		var type = get_tile_type_by_id(id)
		match(type):
			GameboardConstants.WALL_TYPE: entities.append(TileDTO.new(id, GameboardConstants.BLOCK_LAYER, pos.x, pos.y))
			GameboardConstants.SPAWNER_TYPE: entities.append(SpawnerDTO.new(id, GameboardConstants.BLOCK_LAYER,  pos.x, pos.y,_get_spawner_idx_at(Vector2(pos.x,pos.y))))
			GameboardConstants.PLAYER_BASE_TYPE: entities.append(PlayerBaseDTO.new(id, GameboardConstants.BLOCK_LAYER, pos.x, pos.y))
		
	for pos in board.get_used_cells(GameboardConstants.GROUND_LAYER):
		var id = board.get_cell_source_id(GameboardConstants.GROUND_LAYER, pos)
		entities.append(TileDTO.new(id, GameboardConstants.GROUND_LAYER, pos.x, pos.y))
	
	var map_dto = MapDTO.new(entities, monster_waves,map_name)
	map_dto.save(map_name)
