extends GameObject2D
class_name LevelEditorBoardHandler

var board: TileMap
var tiles_holders: Array[GameObjectHolder]

var spawner_map_positions: PackedVector2Array = [] #Holds all the spawners on the board. Index indicates which spawner is which.

signal spawner_added
signal spawner_removed

func _init(board: TileMap, tiles_holders: Array[GameObjectHolder]):
	self.board = board
	self.tiles_holders = tiles_holders

func get_spawner_map_positions() -> PackedVector2Array:
	return spawner_map_positions

func _set_board_cell(tile_item: TileSelection.TileItem, map_position: Vector2):
	var handler_layer
	match(tile_item.dto.map_layer):
		GameboardConstants.GROUND_LAYER: handler_layer = 0
		GameboardConstants.BUILD_LAYER: handler_layer = 1
		GameboardConstants.BLOCK_LAYER: handler_layer = 2
	
	board.set_cell(tile_item.dto.map_layer, map_position, tile_item.dto.tile_id, Vector2(0,0))
	var dto = BaseDTO.get_dto_from_json(tile_item.dto.get_json())
	tiles_holders[handler_layer].set_object_at(dto, map_position)

func _clear_board_cell(layer: int, map_position: Vector2):
	var handler_layer
	match(layer):
		GameboardConstants.GROUND_LAYER: handler_layer = 0
		GameboardConstants.BUILD_LAYER: handler_layer = 1
		GameboardConstants.BLOCK_LAYER: handler_layer = 2
	
	board.set_cell(layer, map_position, -1, Vector2(0,0))
	tiles_holders[handler_layer].set_object_at(null, map_position)

func set_cell(tile: TileSelection.TileItem, map_position: Vector2):
	if tile == null: return
	if not _is_in_editor_bounds(map_position): return
	
	var board_type = GameboardConstants.get_tile_type(board, GameboardConstants.BLOCK_LAYER, map_position)
	var is_spawner_below = board_type != null and board_type == GameboardConstants.TileType.SPAWNER
	var type = GameboardConstants.get_tile_type_by_id(board, tile.dto.tile_id)
	if is_spawner_below and type != GameboardConstants.TileType.SPAWNER: #If there is a spawner below, remove it (unless the holding piece is a spawner)
		var i = _get_spawner_idx_at(map_position)
		spawner_map_positions.remove_at(i)
		spawner_removed.emit(i)
	
	
	match (tile.dto.map_layer):
		GameboardConstants.GROUND_LAYER:
			_set_board_cell(tile, map_position)
			
		GameboardConstants.BUILD_LAYER:
			_set_board_cell(tile, map_position)
			_clear_board_cell(GameboardConstants.BLOCK_LAYER, map_position)
			
		GameboardConstants.BLOCK_LAYER:
			if type == GameboardConstants.TileType.SPAWNER:
				if is_spawner_below: return #There is already a spawner below, ignore it
				spawner_map_positions.append(map_position)
				spawner_added.emit()

			_set_board_cell(tile, map_position)
			_clear_board_cell(GameboardConstants.BUILD_LAYER, map_position)

#If the tile is null, it will bucket clear it
func bucket_fill(tile: TileSelection.TileItem, map_position: Vector2):
	if not _is_in_editor_bounds(map_position): return
	
	var tile_layer
	if tile == null:
		tile_layer = get_highest_used_layer(map_position)
	else:
		tile_layer = tile.dto.map_layer
	
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
	_clear_board_cell(layer, map_position)

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
	for tiles_holder in tiles_holders:
		var objects = tiles_holder.get_objects()
		for row in objects.size():
			for col in objects[row].size():
				var object = objects[row][col]
				if object == null: continue
				
				if is_instance_of(object, SpawnerDTO):
					var idx = _get_spawner_idx_at(Vector2(row, col))
					object.spawner_id = idx
				
				object.map_x = col
				object.map_y = row
				entities.append(object)
	
	var map_dto = MapDTO.new(entities, monster_waves,map_name)
	map_dto.save(map_name)
