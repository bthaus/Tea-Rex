extends Node2D


var selected_block = [Vector2(-1,0), Vector2(0,0), Vector2(1,0), Vector2(1,1)]

const SELECTION_LAYER = 1
const BLOCK_LAYER = 0

const LEGAL_PLACEMENT_TILE_ID = 0
const ILLEGAL_PLACEMENT_TILE_ID = 1
const BLUE_PIECE_TILE_ID = 2

func _ready():
	$Board.tile_set.tile_size = Vector2(Stats.block_size, Stats.block_size)

func _process(_delta):
	$Board.clear_layer(SELECTION_LAYER)
	var board_pos = $Board.local_to_map(get_local_mouse_position())

	#Draw preview
	if selected_block != null:
		var id = LEGAL_PLACEMENT_TILE_ID if _can_place_block(selected_block, board_pos) else ILLEGAL_PLACEMENT_TILE_ID
		_draw_block(selected_block, board_pos, id, SELECTION_LAYER)
	
func _input(event):
	var board_pos = $Board.local_to_map(get_local_mouse_position())
	if event.is_action_pressed("left_click"):
		if selected_block == null: #Pick up at a block
			pass
		elif _can_place_block(selected_block, board_pos): #Place block down if possible
			_draw_block(selected_block, board_pos, BLUE_PIECE_TILE_ID, BLOCK_LAYER)
	
	if event.is_action_pressed("right_click"):
		var block = _get_block_from_board(board_pos, true)
		_draw_block(block, board_pos, -1, BLOCK_LAYER)
		#selected_block = _rotate_block(selected_block)

func _draw_block(block: PackedVector2Array, position: Vector2, id: int, layer: int):
	for piece in block:
		$Board.set_cell(layer, Vector2(piece.x + position.x, piece.y + position.y), id, Vector2(0,0))

#If normalized, the coordinates of each piece will be based on position (=> (0,0))
func _get_block_from_board(position: Vector2, normalize: bool) -> PackedVector2Array:
	var data = $Board.get_cell_tile_data(BLOCK_LAYER, position)
	if data == null: #No tile available
		return []
		
	var color = data.get_custom_data("color")
	var pieces = []
	var stack = [position]
	while !stack.is_empty():
		var curr_position = stack.pop_front()
		pieces.push_back(curr_position)
		for row in range(-1,2):
			for col in range(-1,2):
				var pos = Vector2(curr_position.x+col, curr_position.y+row)

				if pieces.has(pos) or stack.has(pos): continue #Piece is already present in either all the visited pieces or the current stack
			
				var cell_data = $Board.get_cell_tile_data(BLOCK_LAYER, pos)
				if cell_data != null and cell_data.get_custom_data("color") == color:
					stack.push_front(pos)
	
	if normalize:
		for i in pieces.size():
			pieces[i].x -= position.x
			pieces[i].y -= position.y
	return pieces

#Rotates all the pieces of a block from the origin point (0,0)
func _rotate_block(block: PackedVector2Array):
	for i in block.size():
		var piece = block[i]
		piece.y *= -1 #Vector has positive side upwards, exactly opposite of tilemap
		piece = piece.rotated(deg_to_rad(-90)) #This method rotates counter-clockwise, so we need to add the sign
		piece.y *= -1 #Convert back
		piece.x = round(piece.x) #Dont ask me, i hate it
		piece.y = round(piece.y)
		block[i] = piece
	return block
	
#Again, checks based upon (0,0) position of block
func _can_place_block(block: PackedVector2Array, position: Vector2) -> bool:
	for piece in block:
		if $Board.get_cell_source_id(BLOCK_LAYER, Vector2(piece.x + position.x, piece.y + position.y)) != -1:
			return false
	return true
	
