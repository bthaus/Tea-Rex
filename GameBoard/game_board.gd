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

const LEGAL_PLACEMENT_TILE_ID = 1
const ILLEGAL_PLACEMENT_TILE_ID = 2
const WALL_TILE_ID = 3

func _ready():
	$Board.tile_set.tile_size = Vector2(Stats.block_size, Stats.block_size)
	
	# draw a test block
	var block = Block.new([Block.Piece.new(Vector2(0,0), Stats.TurretColor.RED, 2)]) 
	block_handler.draw_block(block, Vector2(6,6), BLOCK_LAYER)
	$Board.set_cell(BLOCK_LAYER, Vector2(10,10), WALL_TILE_ID, Vector2(0,0))
	_draw_wall()


func _process(_delta):
	$Board.clear_layer(SELECTION_LAYER)
	var board_pos = $Board.local_to_map(get_global_mouse_position())
	
	#Draw preview
	if selected_block != null:
		var id = LEGAL_PLACEMENT_TILE_ID if block_handler.can_place_block(selected_block, BLOCK_LAYER, board_pos) else ILLEGAL_PLACEMENT_TILE_ID
		block_handler.draw_block_with_id(selected_block, board_pos, id, SELECTION_LAYER)

func _input(event):
	var board_pos = $Board.local_to_map(get_global_mouse_position())
	if event.is_action_pressed("left_click"):
		if selected_block == null: #Pick up at a block
			var block = block_handler.get_block_from_board(board_pos, BLOCK_LAYER, true)
			block_handler.remove_block_from_board(block, board_pos, BLOCK_LAYER)
			selected_block = block
			
		elif block_handler.can_place_block(selected_block, BLOCK_LAYER, board_pos): #Place block down if possible
			var data = $Board.get_cell_tile_data(BLOCK_LAYER, board_pos)
			if data != null: #There is already a piece -> upgrade
				var level = data.get_custom_data("level")
				block_handler.set_block_level(selected_block, level + 1)
	
			block_handler.draw_block(selected_block, board_pos, BLOCK_LAYER)
	
	if event.is_action_pressed("right_click"):
		block_handler.rotate_block(selected_block)
		#selected_block = null	

func _draw_wall():
	for row in Stats.board_height:
		$Board.set_cell(BLOCK_LAYER, Vector2(0,row), WALL_TILE_ID, Vector2(0,0))
		$Board.set_cell(BLOCK_LAYER, Vector2(Stats.board_width-1,row), WALL_TILE_ID, Vector2(0,0))
	
	for col in Stats.board_width:
		$Board.set_cell(BLOCK_LAYER, Vector2(col,0), WALL_TILE_ID, Vector2(0,0))
		$Board.set_cell(BLOCK_LAYER, Vector2(col,Stats.board_height-1), WALL_TILE_ID, Vector2(0,0))
