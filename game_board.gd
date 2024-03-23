extends Node2D


var block = [Vector2(-1,0), Vector2(-1,-1), Vector2(0,0), Vector2(1,0), Vector2(1,1)]
var board_width = 32
var board_height = 32

const SELECTION_LAYER = 0
const BLOCK_LAYER = 1

func _process(delta):
	$Board.clear_layer(SELECTION_LAYER)
	var board_pos = $Board.local_to_map(get_local_mouse_position())
	_draw_block(block, board_pos, 0, SELECTION_LAYER)
	print(block)
	
func _input(event):
	if Input.is_action_just_pressed("left_click"):
		var board_pos = $Board.local_to_map(get_local_mouse_position())
		_draw_block(block, board_pos, 1, BLOCK_LAYER)
		
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
		piece.x = round(piece.x)
		piece.y = round(piece.y)
		block[i] = piece
	return block
