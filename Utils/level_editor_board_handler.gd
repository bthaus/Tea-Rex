extends GameObject2D
class_name LevelEditorBoardHandler

var board: TileMap
var editor_game_state: EditorGameState

var spawner_map_positions: PackedVector2Array = [] #Holds all the spawners on the board. Index indicates which spawner is which.
var chapters: MapChapterDTO

signal spawner_added
signal spawner_removed

signal base_added
signal base_removed(base)

func _init(board: TileMap):
	self.board = board
	chapters = MapChapterDTO.new()
	chapters.restore()

func _place_entity(entity: BaseEntity, refresh_spawner_paths: bool = true):
	_clear_entity(entity.map_layer, entity.map_position, false) #Clear anything that is at this position
	entity.place_on_board(board)
	if refresh_spawner_paths:
		Spawner.refresh_all_paths()

func _clear_entity(layer: int, map_position: Vector2, refresh_spawner_paths: bool = true):
	var entity = editor_game_state.collisionReference.get_entity(layer, map_position) as BaseEntity
	if entity != null:
		entity.remove_from_board(board)
		#editor_game_state.collisionReference.remove_entity_from_position(entity, board.map_to_local(map_position))
		if entity is PlayerBase:
			base_removed.emit(entity)
		entity.queue_free()
		

	board.set_cell(layer, map_position, -1, Vector2(0,0))
	if refresh_spawner_paths:
		Spawner.refresh_all_paths()

func set_cell(tile: TileSelection.TileItem, map_position: Vector2, refresh_spawner_paths: bool = true):
	if tile == null: return
	if not _is_in_editor_bounds(map_position): return
	
	var entity = GameboardConstants.tile_to_dto(tile.tile_id).get_object()
	entity.map_position = map_position
	
	var board_block_entity = editor_game_state.collisionReference.get_entity(GameboardConstants.MapLayer.BLOCK_LAYER, map_position)
	var is_spawner_below = board_block_entity != null and board_block_entity is Spawner
	
	match (tile.map_layer):
		GameboardConstants.MapLayer.GROUND_LAYER:
			_place_entity(entity, refresh_spawner_paths)
			
		GameboardConstants.MapLayer.BUILD_LAYER:
			_place_entity(entity, refresh_spawner_paths)
			if is_spawner_below:
				_remove_spawner_at(map_position)
			_clear_entity(GameboardConstants.MapLayer.BLOCK_LAYER, map_position, refresh_spawner_paths)
			
		GameboardConstants.MapLayer.BLOCK_LAYER:
			if entity is Spawner:
				if is_spawner_below: return #There is already a spawner below, ignore it
				spawner_map_positions.append(map_position)
				_place_entity(entity, refresh_spawner_paths)
				_clear_entity(GameboardConstants.MapLayer.BUILD_LAYER, map_position, refresh_spawner_paths)
				spawner_added.emit()
				return
			
			if is_spawner_below: #Spawner is below + we are not holding a spawner
				_remove_spawner_at(map_position)
			
			if entity is PlayerBase:
				base_added.emit()
			
			_place_entity(entity, refresh_spawner_paths)
			_clear_entity(GameboardConstants.MapLayer.BUILD_LAYER, map_position, refresh_spawner_paths)

#If the tile is null, it will bucket clear it
func bucket_fill(tile: TileSelection.TileItem, map_position: Vector2):
	if not _is_in_editor_bounds(map_position): return
	
	var tile_layer
	if tile == null:
		tile_layer = get_highest_used_layer(map_position)
	else:
		tile_layer = tile.map_layer
	
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
				if tile_layer != GameboardConstants.MapLayer.BLOCK_LAYER and board.get_cell_source_id(GameboardConstants.MapLayer.BLOCK_LAYER, pos) != -1:
					continue
				
				var tile_id = board.get_cell_source_id(tile_layer, pos)
				if tile_id == board_id:
					if tile == null: clear_cell_at_highest_layer(pos, false)
					else: set_cell(tile, pos, false)
					
					if not (visited.has(pos) or stack.has(pos)): #Piece is already present in either all the visited pieces or the current stack
						stack.push_front(pos)
	
	Spawner.refresh_all_paths()


#Clears the the cell with the highest layer
func clear_cell_at_highest_layer(map_position: Vector2, refresh_spawner_paths: bool = true):
	if not _is_in_editor_bounds(map_position): return
	
	var entity = editor_game_state.collisionReference.get_entity(GameboardConstants.MapLayer.BLOCK_LAYER, map_position)
	if entity != null and entity is Spawner: #There was a spawner below
		_remove_spawner_at(map_position)
	
	#Clear one layer at a time: Block -> Build -> GROUND
	var layer = get_highest_used_layer(map_position)
	if layer == -1: return
	_clear_entity(layer, map_position, refresh_spawner_paths)

func get_highest_used_layer(map_position: Vector2) -> int:
	if not _is_cell_empty(GameboardConstants.MapLayer.BLOCK_LAYER, map_position):
		return GameboardConstants.MapLayer.BLOCK_LAYER
	elif not _is_cell_empty(GameboardConstants.MapLayer.BUILD_LAYER, map_position):
		return GameboardConstants.MapLayer.BUILD_LAYER
	elif not _is_cell_empty(GameboardConstants.MapLayer.GROUND_LAYER, map_position):
		return GameboardConstants.MapLayer.GROUND_LAYER
	return -1

func _is_cell_empty(layer: int, map_position: Vector2):
	return board.get_cell_source_id(layer, map_position) == -1
	
func _is_in_editor_bounds(map_position: Vector2) -> bool:
	if map_position.x < 0 or map_position.x > GameboardConstants.BOARD_WIDTH - 1: return false
	if map_position.y < 0 or map_position.y > GameboardConstants.BOARD_HEIGHT - 1: return false
	return true

func _remove_spawner_at(map_position: Vector2):
	var idx = _get_spawner_idx_at(map_position)
	spawner_map_positions.remove_at(idx)
	for i in editor_game_state.spawners.size():
		if editor_game_state.spawners[i].map_position == map_position:
			var entity = editor_game_state.spawners[i]
			editor_game_state.spawners.remove_at(i)
			entity.queue_free()
			break
			
	spawner_removed.emit(idx)

func _get_spawner_idx_at(map_position: Vector2) -> int:
	for i in spawner_map_positions.size():
		if spawner_map_positions[i] == map_position:
			return i
	return -1

func save_board(monster_waves, setting_properties: LevelEditorSettings.Properties, map_name: String):
	var entities:Array[BaseDTO] = []
	
	for pos in board.get_used_cells(GameboardConstants.MapLayer.GROUND_LAYER): entities.append(_get_entity(GameboardConstants.MapLayer.GROUND_LAYER, pos))
	for pos in board.get_used_cells(GameboardConstants.MapLayer.BUILD_LAYER): entities.append(_get_entity(GameboardConstants.MapLayer.BUILD_LAYER, pos))
	for pos in board.get_used_cells(GameboardConstants.MapLayer.BLOCK_LAYER): entities.append(_get_entity(GameboardConstants.MapLayer.BLOCK_LAYER, pos))
	
	var battle_slot_dto = BattleSlotDTO.new()
	battle_slot_dto.amount = setting_properties.battle_slots_amount
	var map_dto = MapDTO.new(entities, monster_waves, setting_properties.block_cycle, setting_properties.color_cycle, battle_slot_dto, map_name)
	var ids=GameState.gameState.map_dto.treasure_ids
	map_dto.treasure_ids=ids
	map_dto.save(map_name)
	
	chapters.add_map_to_chapter(map_name, GameplayConstants.CUSTOM_LEVELS_CHAPTER_NAME)

func _get_entity(layer: int, map_position: Vector2):
	var entity = GameboardConstants.tile_to_dto(board.get_cell_source_id(layer, map_position))
	entity.map_x = map_position.x
	entity.map_y = map_position.y
	if is_instance_of(entity, SpawnerDTO):
		entity.spawner_id = _get_spawner_idx_at(map_position)
	
	return entity
