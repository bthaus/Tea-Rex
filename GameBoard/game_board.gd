extends Node2D

	
var color = Stats.TurretColor.BLUE
var selected_block = Block.new(
	[
		Block.Piece.new(Vector2(-1,0), color, 1),
		Block.Piece.new(Vector2(0,0), color, 1),
		Block.Piece.new(Vector2(1,0), color, 1),
		Block.Piece.new(Vector2(1,1), color, 1),
	]
)

@onready var block_handler = BlockHandler.new($Board)

const SELECTION_LAYER = 1
const BLOCK_LAYER = 0

const LEGAL_PLACEMENT_TILE_ID = 0
const ILLEGAL_PLACEMENT_TILE_ID = 1
const BLUE_PIECE_TILE_ID = 2
const RED_PIECE_TILE_ID = 3

func _ready():
	$Board.tile_set.tile_size = Vector2(Stats.block_size, Stats.block_size)
	
	# draw a test block
	var block = Block.new([Block.Piece.new(Vector2(0,0), color, 1)]) 
	block_handler.draw_block(block, Vector2(6,6), RED_PIECE_TILE_ID, BLOCK_LAYER)

	
func _process(_delta):
	$Board.clear_layer(SELECTION_LAYER)
	var board_pos = $Board.local_to_map(get_local_mouse_position())
	
	#Draw preview
	if selected_block != null:
		var id = LEGAL_PLACEMENT_TILE_ID if block_handler.can_place_block(selected_block, BLOCK_LAYER, board_pos) else ILLEGAL_PLACEMENT_TILE_ID
		block_handler.draw_block(selected_block, board_pos, id, SELECTION_LAYER)

func _input(event):
	var board_pos = $Board.local_to_map(get_local_mouse_position())
	if event.is_action_pressed("left_click"):
		if selected_block == null: #Pick up at a block
			var block = block_handler.get_block_from_board(board_pos, BLOCK_LAYER, true)
			block_handler.remove_block_from_board(block, board_pos, BLOCK_LAYER)
			selected_block = block
			
		elif block_handler.can_place_block(selected_block, BLOCK_LAYER, board_pos): #Place block down if possible
			block_handler.draw_block(selected_block, board_pos, BLUE_PIECE_TILE_ID, BLOCK_LAYER)
	
	if event.is_action_pressed("right_click"):
		selected_block = block_handler.rotate_block(selected_block)
		#selected_block = null
