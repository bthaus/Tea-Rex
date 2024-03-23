extends Node2D


var block = [Vector2(0,1), Vector2(0,0), Vector2(0,-1), Vector2(1,-1)]
var board_width = 32
var board_height = 32

const SELECTION_LAYER = 0
const BLOCK_LAYER = 1


func _process(delta):
	$Board.clear_layer(SELECTION_LAYER)
	var board_pos = $Board.local_to_map(get_local_mouse_position())
	_draw_block(block, board_pos, 0, SELECTION_LAYER)
	#var mouse_pos = get_local_mouse_position()
	#var board_pos = $Board.local_to_map(mouse_pos)
	#$Board.set_cell(0, board_pos, 0, Vector2(0,0))
	

func _input(event):
	if Input.is_action_just_pressed("left_click"):
		var board_pos = $Board.local_to_map(get_local_mouse_position())
		_draw_block(block, board_pos, 1, BLOCK_LAYER)
		print(board_pos)

func _draw_block(block: PackedVector2Array, position: Vector2, id: int, layer: int):
	var test = 0
	for piece in block:
		$Board.set_cell(layer, Vector2(piece.x + position.x, piece.y + position.y), id, Vector2(0,0))
