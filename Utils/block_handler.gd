extends GameObject2D

class_name BlockHandler
var board: TileMap
var gameState:GameState
var turret_holder: GameObjectHolder

func _init(board: TileMap, turret_holder: GameObjectHolder):
	self.board = board
	self.gameState=GameState.gameState
	self.turret_holder = turret_holder

#Returns the tile id for a piece. Example: Blue tower with level 12 -> Blue has enum value 5 -> id = 512
func get_tile_id_from_block_piece(piece: Block.Piece) -> int:
	return piece.color * 100 + piece.level

#Draws a normalized block at a given map_position. Gets tile from color + level
func draw_block(block: Block, map_position: Vector2):
	for piece in block.pieces:
		var piece_id = get_tile_id_from_block_piece(piece)
		board.set_cell(GameboardConstants.MapLayer.BLOCK_LAYER, Vector2(piece.position.x + map_position.x, piece.position.y + map_position.y), piece_id, Vector2(0,0))

#Draws a normalized block at a given map_position. Does NOT draw extensions as it may override stuff (preview)
func draw_block_with_tile_id(block: Block, map_position: Vector2, id: int, layer: int):
	for piece in block.pieces:
		board.set_cell(layer, Vector2(piece.position.x + map_position.x, piece.position.y + map_position.y), id, Vector2(0,0))

#Removes a block from the board (with turrets only)
func remove_block_from_board(block: Block, map_position: Vector2):
	for piece in block.pieces:
		var turret = turret_holder.get_object_at(Vector2(piece.position.x + map_position.x, piece.position.y + map_position.y))
		if turret != null:
			board.set_cell(GameboardConstants.MapLayer.BLOCK_LAYER, Vector2(piece.position.x + map_position.x, piece.position.y + map_position.y), -1, Vector2(0,0))

#If normalized, the coordinates of each piece will be based on map_position (=> (0,0))
func get_block_from_board(map_position: Vector2, normalize: bool, search_diagonal: bool = false, ignore_level: bool = true) -> Block:
	var board_piece = get_piece_from_board(map_position) 
	if board_piece == null: return #Not a type you can retrieve from the board
	var pieces = [board_piece]
	
	var visited = []
	var stack = [map_position]
	while !stack.is_empty():
		var curr_position = stack.pop_front()
		visited.push_back(curr_position)
		
		for row in range(-1,2):
			for col in range(-1,2):
				#Check if position is one of the diagonals, if flag is not set then skip these
				if not search_diagonal and row != 0 and (col == -1 or col == 1):
					continue
					
				var pos = Vector2(curr_position.x+col, curr_position.y+row)
				if visited.has(pos) or stack.has(pos): continue #Piece is already present in either all the visited pieces or the current stack
				
				var piece = get_piece_from_board(pos)
				if piece != null and piece.color == board_piece.color:
					if not ignore_level and piece.level != board_piece.level:
						continue
					stack.push_front(pos)
					pieces.append(piece)
	
	if normalize:
		for i in pieces.size():
			pieces[i].position.x -= map_position.x
			pieces[i].position.y -= map_position.y
			
	return Block.new(pieces)
	
#Note: Walls will be ignored as the information cannot be stored in a piece properly!
func get_piece_from_board(map_position: Vector2) -> Block.Piece:
	var turret = turret_holder.get_object_at(map_position)
	if turret != null: #Turret on top, return data that is stored in it
		return Block.Piece.new(map_position, turret.color, turret.level, turret.extension)
	return null

#Rotates all the pieces of a block from the origin point (0,0)
func rotate_block(block: Block):
	for piece in block.pieces:
		piece.position.y *= -1 #Vector has positive side upwards, exactly opposite of tilemap
		piece.position = piece.position.rotated(deg_to_rad(-90)) #This method rotates counter-clockwise, so we need to add the sign
		piece.position.y *= -1 #Convert back
		piece.position.x = round(piece.position.x) #Dont ask me, i hate it
		piece.position.y = round(piece.position.y)

#Again, checks based upon (0,0) map_position of block
func can_place_block(block: Block, map_position: Vector2,  spawners) -> bool:
	if block.pieces.size() == 0: return true

	#Get the level of the underlying piece on the board, if available (loop will take care if its the wrong color)
	var first_piece = get_piece_from_board(Vector2(block.pieces[0].position.x + map_position.x, block.pieces[0].position.y + map_position.y))
	var max_level_turret_count = 0
	
	var spawner_positions = []
	for spawner in spawners:
		spawner_positions.append(board.local_to_map(spawner.position))

	for piece in block.pieces:
		var board_pos = Vector2(piece.position.x + map_position.x, piece.position.y + map_position.y)
		
		#Check if there is ground
		if board.get_cell_source_id(GameboardConstants.MapLayer.GROUND_LAYER, board_pos) == -1:
			GameBoard.current_tutorial = TutorialHolder.tutNames.Outside
			print("yo theat outside")
			return false
		
		
		#Check if there is a block place restriction
		var build_entity = GameState.collisionReference.get_entity(GameboardConstants.MapLayer.BUILD_LAYER, board_pos)
		if build_entity != null and build_entity is BuildEntity: #There is a build restriction present
			if build_entity.allowed_color == GameboardConstants.TileColor.NONE: #No color allowed here
				return false
			if build_entity.allowed_color != GameboardConstants.turret_color_to_tile_color(piece.color): #Wrong color
				return false
		
		#Check underlying piece
		var board_piece = get_piece_from_board(board_pos)
		if (board_piece != null and first_piece == null) or (board_piece == null and first_piece != null): #Either no blocks below or all blocks!
			GameBoard.current_tutorial = null
			return false
		
		if board_piece != null: #Tile exists at this position
			if board_piece.color == Turret.Hue.WHITE: #You can NEVER place something on white
				GameBoard.current_tutorial = TutorialHolder.tutNames.ColorRestriction
				return false
			if board_piece.color != piece.color: #Wrong color	
				GameBoard.current_tutorial = TutorialHolder.tutNames.ColorRestriction
				return false
			
			if turret_holder.get_object_at(board_pos).is_max_level():
				max_level_turret_count += 1
				if max_level_turret_count == block.pieces.size(): #All turrets below are already at max level
					GameBoard.current_tutorial = null
					return false
		
		
		#Check near mismatching colors
		for row in range(-1,2):
			for col in range(-1,2):
				var pos = Vector2(board_pos.x+col, board_pos.y+row)
				if piece.color != Turret.Hue.WHITE: #Checking surrounding pieces is only for colored blocks neccessary
					var neighbour_piece = get_piece_from_board(pos)
					if neighbour_piece != null:
						if neighbour_piece.color != piece.color and neighbour_piece.color != Turret.Hue.WHITE: #Mismatching colors (white pieces are an exception)
								GameBoard.current_tutorial = TutorialHolder.tutNames.ColorRestriction
								return false
	
	#Check if a path would be valid
	if first_piece == null: #We want to build something new (no upgrade)
		draw_block_with_tile_id(block, map_position, GameboardConstants.BASE_PREVIEW_TILE_ID, GameboardConstants.MapLayer.BLOCK_LAYER) #Draw preview block for path
		Spawner.refresh_all_paths()
		var can_all_reach = Spawner.can_all_reach_target()
		remove_block_from_board(block, map_position) #Delete preview block again
		if not can_all_reach:
			GameBoard.current_tutorial = TutorialHolder.tutNames.Pathfinding
			return false
	
	GameBoard.current_tutorial = null
	return true
