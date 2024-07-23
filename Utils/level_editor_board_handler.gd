extends GameObject2D
class_name LevelEditorBoardHandler

var board: TileMap

var spawner_map_positions: PackedVector2Array = [] #Holds all the spawners on the board. Index indicates which spawner is which.

signal spawner_added
signal spawner_removed

func _init(board: TileMap):
	self.board = board

func get_spawner_map_positions() -> PackedVector2Array:
	return spawner_map_positions

func set_cell(tile: LevelEditor.TileItem, map_position: Vector2):
	if tile == null: return
	if not _is_in_editor_bounds(map_position): return
	
	var board_type = GameboardConstants.get_tile_type(board, GameboardConstants.BLOCK_LAYER, map_position)
	var is_spawner_below = board_type != null and board_type == GameboardConstants.TileType.SPAWNER
	var type = GameboardConstants.get_tile_type_by_id(board, tile.id)
	if is_spawner_below and type != GameboardConstants.TileType.SPAWNER: #If there is a spawner below, remove it (unless the holding piece is a spawner)
		var i = _get_spawner_idx_at(map_position)
		spawner_map_positions.remove_at(i)
		spawner_removed.emit(i)
	
	
	match (tile.layer):
		GameboardConstants.GROUND_LAYER:
			board.set_cell(GameboardConstants.GROUND_LAYER, map_position, tile.id, Vector2(0,0))
			
		GameboardConstants.BUILD_LAYER:
			board.set_cell(GameboardConstants.BUILD_LAYER, map_position, tile.id, Vector2(0,0))
			board.set_cell(GameboardConstants.BLOCK_LAYER, map_position, -1, Vector2(0,0))
			
		GameboardConstants.BLOCK_LAYER:
			if type == GameboardConstants.TileType.SPAWNER:
				if is_spawner_below: return #There is already a spawner below, ignore it
				spawner_map_positions.append(map_position)
				spawner_added.emit()

			board.set_cell(GameboardConstants.BLOCK_LAYER, map_position, tile.id, Vector2(0,0))
			board.set_cell(GameboardConstants.BUILD_LAYER, map_position, -1, Vector2(0,0))

#If the tile is null, it will bucket clear it
func bucket_fill(tile: LevelEditor.TileItem, map_position: Vector2):
	if not _is_in_editor_bounds(map_position): return
	
	var tile_layer
	if tile == null:
		tile_layer = get_highest_used_layer(map_position)
	else:
		tile_layer = tile.layer
	
	var board_id = board.get_cell_source_id(tile_layer, map_position) #underlying tile
	var visited = []
	var stack = [map_position]
	while !stack.is_empty():
		var curr_position = stack.pop_front()
		visited.push_back(curr_position)
		
		for row in range(-1,2):
			for col in range(-1,2):
				#Skip diagonal cases
				if row != 0 and (col == -1 or col == 1):
					continue
					
				var pos = Vector2(curr_position.x+col, curr_position.y+row)
				if not _is_in_editor_bounds(pos): continue
				
				#Check if there is a block layer tile, do not search in that case (unless the tile we wanna place is from the block layer)
				if tile_layer != GameboardConstants.BLOCK_LAYER and board.get_cell_source_id(GameboardConstants.BLOCK_LAYER, pos) != -1:
					continue
				
				var tile_id = board.get_cell_source_id(tile_layer, pos)
				if tile_id == board_id:
					if tile == null: clear_cell_layer(pos)
					else: set_cell(tile, pos)
					
					if not (visited.has(pos) or stack.has(pos)): #Piece is already present in either all the visited pieces or the current stack
						stack.push_front(pos)
	

func clear_cell_layer(map_position: Vector2):
	var board_type = GameboardConstants.get_tile_type(board, GameboardConstants.BLOCK_LAYER, map_position)
	if board_type != null and board_type == GameboardConstants.TileType.SPAWNER: #There was a spawner below
			var i = _get_spawner_idx_at(map_position)
			spawner_map_positions.remove_at(i)
			spawner_removed.emit(i)
	
	#Clear one layer at a time: Block -> Build -> GROUND
	var layer = get_highest_used_layer(map_position)
	if layer == -1: return
	board.set_cell(layer, map_position, -1, Vector2(0,0))

func get_highest_used_layer(map_position: Vector2) -> int:
	if not _is_cell_empty(GameboardConstants.BLOCK_LAYER, map_position):
		return GameboardConstants.BLOCK_LAYER
	elif not _is_cell_empty(GameboardConstants.BUILD_LAYER, map_position):
		return GameboardConstants.BUILD_LAYER
	elif not _is_cell_empty(GameboardConstants.GROUND_LAYER, map_position):
		return GameboardConstants.GROUND_LAYER
	return -1

func _is_cell_empty(layer: int, map_position: Vector2):
	return board.get_cell_source_id(layer, map_position) == -1
	
func _is_in_editor_bounds(map_position: Vector2) -> bool:
	if map_position.x < 0 or map_position.x > GameboardConstants.BOARD_WIDTH - 1: return false
	if map_position.y < 0 or map_position.y > GameboardConstants.BOARD_HEIGHT - 1: return false
	return true

func _get_spawner_idx_at(map_position: Vector2) -> int:
	for i in spawner_map_positions.size():
		if spawner_map_positions[i] == map_position:
			return i
	return -1

func save_board(monster_waves,map_name):
	var entities:Array[BaseDTO] = []
	
	#Store block layer
	for pos in board.get_used_cells(GameboardConstants.BLOCK_LAYER):
		var id = board.get_cell_source_id(GameboardConstants.BLOCK_LAYER, pos)
		var type = GameboardConstants.get_tile_type_by_id(board, id)
		match(type):
			GameboardConstants.TileType.WALL: entities.append(TileDTO.new(id, GameboardConstants.BLOCK_LAYER, pos.x, pos.y,true))
			GameboardConstants.TileType.SPAWNER: 
				var idx = _get_spawner_idx_at(Vector2(pos.x, pos.y))
				var color = GameboardConstants.get_tile_color(board, GameboardConstants.BLOCK_LAYER, pos)
				entities.append(SpawnerDTO.new(id, GameboardConstants.BLOCK_LAYER, pos.x, pos.y, idx, color))
			GameboardConstants.TileType.PLAYER_BASE: entities.append(PlayerBaseDTO.new(id, GameboardConstants.BLOCK_LAYER, pos.x, pos.y))
			GameboardConstants.TileType.PORTAL: entities.append(PortalDTO.new(id, GameboardConstants.BLOCK_LAYER, Vector2(pos.x, pos.y)))
	
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
