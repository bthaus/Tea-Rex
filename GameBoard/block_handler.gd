extends Node

class_name BlockHandler
var board: TileMap
func _init(board: TileMap):
	self.board = board

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
		board.set_cell(extension_layer, Vector2(piece.position.x + position.x, piece.position.y + position.y), -1, Vector2(0,0))

#If normalized, the coordinates of each piece will be based on position (=> (0,0))
func get_block_from_board(position: Vector2, block_layer: int, extension_layer: int, normalize: bool) -> Block:
	var data = board.get_cell_tile_data(block_layer, position)
	if data == null: #No tile available
		return Block.new([])
		
	var color = data.get_custom_data("color")
	var visited = []
	var pieces = [Block.Piece.new(position, Stats.TurretColor.get(color.to_upper()), data.get_custom_data("level"))]
	var stack = [position]
	while !stack.is_empty():
		var curr_position = stack.pop_front()
		visited.push_back(curr_position)
		
		for row in range(-1,2):
			for col in range(-1,2):
				var pos = Vector2(curr_position.x+col, curr_position.y+row)
				if visited.has(pos) or stack.has(pos): continue #Piece is already present in either all the visited pieces or the current stack
			
				var cell_block_data = board.get_cell_tile_data(block_layer, pos)
				var cell_extension_data = board.get_cell_tile_data(extension_layer, pos)
				if cell_block_data != null and cell_block_data.get_custom_data("color") == color:
					stack.push_front(pos)
					pieces.append(Block.Piece.new(
						pos, 
						Stats.TurretColor.get(color.to_upper()), 
						cell_block_data.get_custom_data("level"),
						Stats.TurretExtension.get(cell_extension_data.get_custom_data("extension").to_upper())
						))
					
	
	if normalize:
		for i in pieces.size():
			pieces[i].position.x -= position.x
			pieces[i].position.y -= position.y
			
	return Block.new(pieces)

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
func can_place_block(block: Block, layer: int, position: Vector2) -> bool:
	if block.pieces.size() == 0: return true

	#Get the level of the underlying piece on the board, if available (loop will take care if its the wrong color)
	#If the level is -1 it means that there is an empty cell
	var first_piece_data = board.get_cell_tile_data(layer, Vector2(block.pieces[0].position.x + position.x, block.pieces[0].position.y + position.y))
	var level = -1 if first_piece_data == null else first_piece_data.get_custom_data("level")

	for piece in block.pieces:
		var board_pos = Vector2(piece.position.x + position.x, piece.position.y + position.y)
		if board_pos.x <= 0 or board_pos.x >= Stats.board_width-1 or board_pos.y <= 0 or board_pos.y >= Stats.board_height-1: #Piece is out of bounds (walls)
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
		
		if piece.color == Stats.TurretColor.GREY: #For grey pieces we do not have to check surrounding pieces
			continue
			
		#Check near mismatching colors
		for row in range(-1,2):
			for col in range(-1,2):
				var pos = Vector2(board_pos.x+col, board_pos.y+row)
				var cell_data = board.get_cell_tile_data(layer, pos)
				if cell_data != null:
					var color = cell_data.get_custom_data("color").to_upper()
					if color != "WALL" and color != Stats.getStringFromEnum(Stats.TurretColor.GREY): #Walls and grey pieces are an exception, ignore them
						if color != Stats.getStringFromEnum(piece.color): #Mismatching color
							return false
				
	return true
	
