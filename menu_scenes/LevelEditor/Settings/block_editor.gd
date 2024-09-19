extends Panel

var previous_board_position = Vector2(-1, -1)
var block: Block = Block.new([])
signal saved
signal canceled

func _ready():
	hide()

func set_block(block: Block):
	self.block = block
	$Board.clear_layer(GameboardConstants.MapLayer.BLOCK_LAYER)
	for piece in block.pieces:
		$Board.set_cell(GameboardConstants.MapLayer.BLOCK_LAYER, piece.position, GameboardConstants.WALL_TILE_ID, Vector2(0,0))

func _input(event):
	var mouse_just_pressed = InputUtils.is_action_just_pressed(event, "left_click") or InputUtils.is_action_just_pressed(event, "right_click")
	var mouse_just_released = InputUtils.is_action_just_released(event, "left_click") or InputUtils.is_action_just_released(event, "right_click")
	var board_pos = GameboardUtils.local_to_map_on_scaled_board($Board, get_local_mouse_position())
	
	#Check if we are at a new tile
	var at_new_tile = true if board_pos != previous_board_position else false
	previous_board_position = board_pos
	
	if at_new_tile or mouse_just_pressed or mouse_just_released:
		if $Board.get_cell_source_id(GameboardConstants.MapLayer.GROUND_LAYER, board_pos) == -1: return #Check if invalid position
		#Input should technically not be used in _input... but it works
		if Input.is_action_pressed("left_click"):
			$Board.set_cell(GameboardConstants.MapLayer.BLOCK_LAYER, board_pos, GameboardConstants.WALL_TILE_ID, Vector2(0,0))
		elif Input.is_action_pressed("right_click"):
			$Board.set_cell(GameboardConstants.MapLayer.BLOCK_LAYER, board_pos, -1, Vector2(0,0))

func open():
	$OpenCloseScaleAnimation.open()
	
func close():
	$OpenCloseScaleAnimation.close(func(): queue_free)

func _on_cancel_button_pressed():
	canceled.emit()
	close()

func _on_save_button_pressed():
	var pieces: Array[Block.Piece] = []
	for pos in $Board.get_used_cells(GameboardConstants.MapLayer.BLOCK_LAYER):
		pieces.append(Block.Piece.new(pos, Turret.Hue.WHITE, 1))
	saved.emit(Block.new(pieces))
	close()
