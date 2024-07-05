extends GameObject2D
class_name LevelEditorBoardHandler

var board: TileMap

var spawner_positions: PackedVector2Array = [] #Holds all the spawners on the board. Index indicates which spawner is which.

signal spawner_added
signal spawner_removed

func _init(board: TileMap):
	self.board = board

func set_cell(id: int, map_position: Vector2):
	if not _is_in_editor_bounds(map_position): return
	
	var board_type = GameboardConstants.get_tile_type(board, GameboardConstants.BLOCK_LAYER, map_position)
	var is_spawner_below = board_type != null and board_type == GameboardConstants.TileType.SPAWNER
	var type = GameboardConstants.get_tile_type_by_id(board, id)
	if is_spawner_below and type != GameboardConstants.TileType.SPAWNER: #If there is a spawner below, remove it (unless the holding piece is a spawner)
		var i = _get_spawner_idx_at(map_position)
		spawner_positions.remove_at(i)
		spawner_removed.emit(i)
			
	match(type):
		GameboardConstants.TileType.GROUND:
			board.set_cell(GameboardConstants.GROUND_LAYER, map_position, id, Vector2(0,0))
			board.set_cell(GameboardConstants.BLOCK_LAYER, map_position, -1, Vector2(0,0))
			return
		GameboardConstants.TileType.BUILD:
			board.set_cell(GameboardConstants.BUILD_LAYER, map_position, id, Vector2(0,0))
			board.set_cell(GameboardConstants.BLOCK_LAYER, map_position, -1, Vector2(0,0))
			return
		GameboardConstants.TileType.SPAWNER:
			if is_spawner_below: return #There is already a spawner below, ignore it
			spawner_positions.append(map_position)
			spawner_added.emit()
	
	board.set_cell(GameboardConstants.BLOCK_LAYER, map_position, id, Vector2(0,0))
	board.set_cell(GameboardConstants.BUILD_LAYER, map_position, -1, Vector2(0,0))
	board.set_cell(GameboardConstants.GROUND_LAYER, map_position, -1, Vector2(0,0))
	
func clear_cell_layer(map_position: Vector2):
	var board_type = GameboardConstants.get_tile_type(board, GameboardConstants.BLOCK_LAYER, map_position)
	if board_type != null and board_type == GameboardConstants.TileType.SPAWNER: #There was a spawner below
			var i = _get_spawner_idx_at(map_position)
			spawner_positions.remove_at(i)
			spawner_removed.emit(i)
	
	#Clear one layer at a time: Block -> Build -> GROUND
	if not _is_cell_empty(GameboardConstants.BLOCK_LAYER, map_position):
		board.set_cell(GameboardConstants.BLOCK_LAYER, map_position, -1, Vector2(0,0))
	elif not _is_cell_empty(GameboardConstants.BUILD_LAYER, map_position):
		board.set_cell(GameboardConstants.BUILD_LAYER, map_position, -1, Vector2(0,0))
	else:
		board.set_cell(GameboardConstants.GROUND_LAYER, map_position, -1, Vector2(0,0))

func _is_cell_empty(layer: int, map_position: Vector2):
	return board.get_cell_source_id(layer, map_position) == -1
	
func _is_in_editor_bounds(map_position: Vector2) -> bool:
	if map_position.x < 0 or map_position.x > Stats.LEVEL_EDITOR_WIDTH - 1: return false
	if map_position.y < 0 or map_position.y > Stats.LEVEL_EDITOR_HEIGHT - 1: return false
	return true

func _get_spawner_idx_at(map_position: Vector2) -> int:
	for i in spawner_positions.size():
		if spawner_positions[i] == map_position:
			return i
	return -1

func save_board(monster_waves,map_name):
	var entities:Array[BaseDTO] = []
	
	#Store block layer
	for pos in board.get_used_cells(GameboardConstants.BLOCK_LAYER):
		var id = board.get_cell_source_id(GameboardConstants.BLOCK_LAYER, pos)
		var type = GameboardConstants.get_tile_type_by_id(board, id)
		match(type):
			GameboardConstants.TileType.WALL: entities.append(TileDTO.new(id, GameboardConstants.BLOCK_LAYER, pos.x, pos.y))
			GameboardConstants.TileType.SPAWNER: 
				var idx = _get_spawner_idx_at(Vector2(pos.x, pos.y))
				var color = GameboardConstants.get_tile_color(board, GameboardConstants.BLOCK_LAYER, pos)
				entities.append(SpawnerDTO.new(id, GameboardConstants.BLOCK_LAYER, pos.x, pos.y, idx, color))
			GameboardConstants.TileType.PLAYER_BASE: entities.append(PlayerBaseDTO.new(id, GameboardConstants.BLOCK_LAYER, pos.x, pos.y))
	
	#Store build layer
	for pos in board.get_used_cells(GameboardConstants.BUILD_LAYER):
		var id = board.get_cell_source_id(GameboardConstants.BUILD_LAYER, pos)
		entities.append(TileDTO.new(id, GameboardConstants.BUILD_LAYER, pos.x, pos.y))
	
	#Store ground layer
	for pos in board.get_used_cells(GameboardConstants.GROUND_LAYER):
		var id = board.get_cell_source_id(GameboardConstants.GROUND_LAYER, pos)
		entities.append(TileDTO.new(id, GameboardConstants.GROUND_LAYER, pos.x, pos.y))
	
	var map_dto = MapDTO.new(entities, monster_waves,map_name)
	map_dto.save(map_name)
