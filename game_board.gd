extends Node2D


var block = [Vector2(-1,0), Vector2(0,0), Vector2(1,0), Vector2(1,1)]
var board_width = 32
var board_height = 32

const SELECTION_LAYER = 1
const BLOCK_LAYER = 0

const LEGAL_PLACEMENT_TILE_ID = 0
const ILLEGAL_PLACEMENT_TILE_ID = 1
const BLUE_PIECE_TILE_ID = 2


func _process(delta):
	$Board.clear_layer(SELECTION_LAYER)
	var board_pos = $Board.local_to_map(get_local_mouse_position())
	
	#Draw preview
	var id = LEGAL_PLACEMENT_TILE_ID if _can_place_block(block, board_pos) else ILLEGAL_PLACEMENT_TILE_ID
	_draw_block(block, board_pos, id, SELECTION_LAYER)
	
func _input(event):
	var board_pos = $Board.local_to_map(get_local_mouse_position())
	if Input.is_action_just_pressed("left_click") and _can_place_block(block, board_pos):
		_draw_block(block, board_pos, BLUE_PIECE_TILE_ID, BLOCK_LAYER)		
	if Input.is_action_just_pressed("right_click"):
		block = _rotate_block(block)

func _draw_block(block: PackedVector2Array, position: Vector2, id: int, layer: int):
	var test = 0
	for piece in block:
		$Board.set_cell(layer, Vector2(piece.x + position.x, piece.y + position.y), id, Vector2(0,0))

#Rotates all the pieces of a block from the origin point (0,0)
func _rotate_block(block: PackedVector2Array):
	for i in block.size():
		var piece = block[i]
		piece.y *= -1 #Vector has positive side upwards, exactly opposite of tilemap
		piece = piece.rotated(deg_to_rad(-90)) #This method rotates counter-clockwise, so we need to add the sign
		piece.y *= -1 #Convert back
		piece.x = round(piece.x) #Dont even ask me, i hate it
		piece.y = round(piece.y)
		block[i] = piece
	return block
	
func _can_place_block(block: PackedVector2Array, position: Vector2) -> bool:
	for piece in block:
		if $Board.get_cell_source_id(BLOCK_LAYER, Vector2(piece.x + position.x, piece.y + position.y)) != -1:
			return false
	return true
	
