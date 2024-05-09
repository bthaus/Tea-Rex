extends Node

class_name BlockHandler
var board: TileMap
var gameState:GameState
func _init(board: TileMap):
	self.board = board
	self.gameState=GameState.gameState
	
	
const PREVIEW_BLOCK_TILE_ID = 4

#Returns the tile id for a piece. Example: Blue tower with level 12 -> Blue has enum value 5 -> id = 512
func get_tile_id_from_block_piece(piece: Block.Piece) -> int:
	return piece.color * 100 + piece.level

#All extensions start from 1000 and use the value from the enum
func get_tile_id_from_extension(extension: Stats.TurretExtension):
	return 1000 + extension

#Draws a normalized block at a given position. Gets tile from color + level
func draw_block(block: Block, position: Vector2, block_layer: int, extension_layer: int):
	for piece in block.pieces:
		var piece_id = get_tile_id_from_block_piece(piece)
		board.set_cell(block_layer, Vector2(piece.position.x + position.x, piece.position.y + position.y), piece_id, Vector2(0,0))
		if extension_layer != -1:
			var extension_id = get_tile_id_from_extension(piece.extension)
			board.set_cell(extension_layer, Vector2(piece.position.x + position.x, piece.position.y + position.y), extension_id, Vector2(0,0))

#Draws a normalized block at a given position. Does NOT draw extensions as it may override stuff (preview)
func draw_block_with_tile_id(block: Block, position: Vector2, id: int, layer: int):
	for piece in block.pieces:
		board.set_cell(layer, Vector2(piece.position.x + position.x, piece.position.y + position.y), id, Vector2(0,0))

func remove_block_from_board(block: Block, position: Vector2, block_layer: int, extension_layer: int, remove_walls: bool):
	for piece in block.pieces:
		if not remove_walls:
			var data = board.get_cell_tile_data(block_layer, Vector2(piece.position.x + position.x, piece.position.y + position.y))
			if data != null and data.get_custom_data("color").to_upper() == "WALL": #Skip walls as they should not be removable by this function
				continue
		board.set_cell(block_layer, Vector2(piece.position.x + position.x, piece.position.y + position.y), -1, Vector2(0,0))
		if extension_layer != -1:
			board.set_cell(extension_layer, Vector2(piece.position.x + position.x, piece.position.y + position.y), -1, Vector2(0,0))

#If normalized, the coordinates of each piece will be based on position (=> (0,0))
func get_block_from_board(position: Vector2, block_layer: int, extension_layer: int, normalize: bool, search_diagonal: bool = false, ignore_level: bool = true) -> Block:
	var data = board.get_cell_tile_data(block_layer, position)
	if data == null: #No tile available
		return Block.new([])
	
	var color = Stats.TurretColor.get(data.get_custom_data("color").to_upper())
	if color == null: return
	var level = data.get_custom_data("level")
	var visited = []
	var pieces = [Block.Piece.new(position, color, data.get_custom_data("level"))]
	var stack = [position]
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
				
				var piece = get_piece_from_board(pos, block_layer, extension_layer)
				if piece != null and piece.color == color:
					if not ignore_level and piece.level != level:
						continue
					stack.push_front(pos)
					pieces.append(piece)
	
	if normalize:
		for i in pieces.size():
			pieces[i].position.x -= position.x
			pieces[i].position.y -= position.y
			
	return Block.new(pieces)
	
#Note: Walls will be ignored as the information cannot be stored in a piece properly!
func get_piece_from_board(position: Vector2, block_layer: int, extension_layer: int) -> Block.Piece:
	var cell_block_data = board.get_cell_tile_data(block_layer, position)
	if cell_block_data == null or cell_block_data.get_custom_data("color").to_upper() == "WALL":
		return null
	var cell_extension_data = board.get_cell_tile_data(extension_layer, position)
	return Block.Piece.new(
						position, 
						Stats.TurretColor.get(cell_block_data.get_custom_data("color").to_upper()), 
						cell_block_data.get_custom_data("level"),
						Stats.TurretExtension.get(cell_extension_data.get_custom_data("extension").to_upper())
						)

#Rotates all the pieces of a block from the origin point (0,0)
func rotate_block(block: Block):
	for piece in block.pieces:
		piece.position.y *= -1 #Vector has positive side upwards, exactly opposite of tilemap
		piece.position = piece.position.rotated(deg_to_rad(-90)) #This method rotates counter-clockwise, so we need to add the sign
		piece.position.y *= -1 #Convert back
		piece.position.x = round(piece.position.x) #Dont ask me, i hate it
		piece.position.y = round(piece.position.y)

func set_block_level(block: Block, level: int):
	for piece in block.pieces:
		piece.level = level

#Again, checks based upon (0,0) position of block
func can_place_block(block: Block, layer: int, position: Vector2, navigation_region: NavigationRegion2D, spawners) -> bool:
	if block.pieces.size() == 0: return true

	#Get the level of the underlying piece on the board, if available (loop will take care if its the wrong color)
	#If the level is -1 it means that there is an empty cell
	var first_piece_data = board.get_cell_tile_data(layer, Vector2(block.pieces[0].position.x + position.x, block.pieces[0].position.y + position.y))
	var level = -1 if first_piece_data == null else first_piece_data.get_custom_data("level")
	
	var spawner_positions = []
	for spawner in spawners:
		spawner_positions.append(board.local_to_map(spawner.position))

	for piece in block.pieces:
		var board_pos = Vector2(piece.position.x + position.x, piece.position.y + position.y)
		if not is_position_in_gameboard_bounds(layer, board_pos): #Check if piece is inside bounds (walls)
			return false
		var board_data = board.get_cell_tile_data(layer, board_pos)
		
		#Check underlying piece
		if board_data != null: #Tile exists at this position
			var board_data_color = board_data.get_custom_data("color").to_upper()
			if board_data_color == Stats.getStringFromEnum(Stats.TurretColor.GREY): #You can NEVER place something on grey
				return false
			if board_data_color != Stats.getStringFromEnum(piece.color): #Wrong color
				return false
			if level != board_data.get_custom_data("level"): #Level does not match
				return false
		elif level != -1: #We expect a non-empty cell
			return false
			
		#Check near mismatching colors
		for row in range(-1,2):
			for col in range(-1,2):
				var pos = Vector2(board_pos.x+col, board_pos.y+row)
				if piece.color != Stats.TurretColor.GREY: #Checking surrounding pieces is only for colored blocks neccessary
					var cell_data = board.get_cell_tile_data(layer, pos)
					if cell_data != null:
						var color = cell_data.get_custom_data("color").to_upper()
						if color != "WALL" and color != Stats.getStringFromEnum(Stats.TurretColor.GREY): #Walls and grey pieces are an exception, ignore them
							if color != Stats.getStringFromEnum(piece.color): #Mismatching color
								return false
				
				#Check if there are any surrounding spawners
				for spawner_pos in spawner_positions:
					if spawner_pos.x == pos.x and spawner_pos.y == pos.y:
						return false
	
	#Block could theoretically be placed to upgrade, but the underlying block already has reached the max level
	if level == Stats.MAX_TURRET_LEVEL:
		return false
	
	#Check if a path would be valid
	if board.get_cell_tile_data(layer, position) == null: #We want to build something new (no upgrade)
		draw_block_with_tile_id(block, position, PREVIEW_BLOCK_TILE_ID, layer) #Draw preview block for path
		navigation_region.bake_navigation_polygon()
		var all_paths_valid = true
		for spawn in spawners:
			if not spawn.can_reach_target():
				all_paths_valid = false
				break
		remove_block_from_board(block, position, layer, -1, false) #Delete preview block again
		if not all_paths_valid:
			return false
		
	return true

#Calculates how long a row (wall to wall) in a gameboard field is and
#returns the points. The walls themselves are excluded
func get_board_distance_at_row(layer: int, row: int) -> util.Distance:
	var col = 0
	var left_side = 0
	var right_side = 1
	var max = 200
	while true:
		var data = board.get_cell_tile_data(layer, Vector2(col, row))
		if data != null and data.get_custom_data("color").to_upper() == "WALL":
			left_side = col+1
			break
		col -= 1
		if -col > max:
			util.p(str("No limit for row ", row, " on left side found! Value ", -max, " will be taken"), "Jojo", "Error")
			left_side = -max
			break
	col = 1
	while true:
		var data = board.get_cell_tile_data(layer, Vector2(col, row))
		if data != null and data.get_custom_data("color").to_upper() == "WALL":
			right_side = col-1
			break
		col += 1
		if col > max:
			util.p(str("No limit for row ", row, " on right side found! Value ", max, " will be taken"), "Jojo", "Error")
			right_side = max
			break
	return util.Distance.new(left_side, right_side)

#Checks if a given position is in bounds the gameboard or not. This is needed since the caves allow a variable width.
#The walls themselves are excluded, meaning positions on these walls will result in being out of bounds.
func is_position_in_gameboard_bounds(layer: int, position: Vector2) -> bool:
	if position.y <= 0 or position.y >= gameState.board_height-1:
		return false
	
	#Check right side
	var x = position.x
	while x >= gameState.board_width-1:
		var data = board.get_cell_tile_data(layer, Vector2(x, position.y))
		if data != null and data.get_custom_data("color").to_upper() == "WALL":
			return false
		x -= 1
	
	#Check left side
	x = position.x
	while x <= 0:
		var data = board.get_cell_tile_data(layer, Vector2(x, position.y))
		if data != null and data.get_custom_data("color").to_upper() == "WALL":
			return false
		x += 1
		
	return true
