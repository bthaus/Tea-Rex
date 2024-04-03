extends Node2D

var selected_block = null

var moved_from_position = Vector2.ZERO #As (0,0) will be part of the wall, it is outside of bounds and can be treated as not initialized
var moved_from_block = null

@onready var block_handler = BlockHandler.new($Board)
enum BoardAction {NONE=0, PLAYER_BUILD=1, PLAYER_MOVE=2, PLAYER_BULLDOZER=3}
var action: BoardAction = BoardAction.NONE
var done: Callable

var is_dragging_camera = false
var ignore_click = false

const EXTENSION_LAYER = 0
const BLOCK_LAYER = 1
const SELECTION_LAYER = 2

const LEGAL_PLACEMENT_TILE_ID = 1
const ILLEGAL_PLACEMENT_TILE_ID = 2
const WALL_TILE_ID = 3

func _ready():
	$Board.tile_set.tile_size = Vector2(Stats.block_size, Stats.block_size)
	
	$Camera2D.is_dragging_camera.connect(dragging_camera)
	# draw a test block
	var block = Stats.getBlockFromShape(Stats.BlockShape.L, Stats.TurretColor.BLUE, 1, Stats.TurretExtension.BLUELASER)
	block_handler.draw_block(block, Vector2(6,6), BLOCK_LAYER, EXTENSION_LAYER)
	$Board.set_cell(BLOCK_LAYER, Vector2(10,10), WALL_TILE_ID, Vector2(0,0))
	_draw_walls()
	_spawn_turrets()

func start_bulldozer(done:Callable, size_x:int, size_y:int):
	util.p("Bulldozering stuff now...", "Jojo")
	var pieces = []
	for row in size_y:
		for col in size_x:
			pieces.push_back(Block.Piece.new(Vector2(-col, -row), Stats.TurretColor.GREY, -1)) #Color has no particular reason
	selected_block = Block.new(pieces)
	action = BoardAction.PLAYER_BULLDOZER
	self.done = done
	
func start_move(done:Callable):
	util.p("Moving stuff now...", "Jojo")
	action = BoardAction.PLAYER_MOVE
	self.done = done
	
func select_piece(shape:Stats.BlockShape, color:Stats.TurretColor, done:Callable, level:int, extension:Stats.TurretExtension=Stats.TurretExtension.DEFAULT):
	util.p("Building now...", "Jojo")
	action = BoardAction.PLAYER_BUILD
	selected_block = Stats.getBlockFromShape(shape, color, level)
	self.done = done
	
func select_block(block,done:Callable):
	util.p("Building now...", "Jojo")
	action = BoardAction.PLAYER_BUILD
	selected_block = block
	self.done = done
	
func _process(_delta):
	$Board.clear_layer(SELECTION_LAYER)
	var board_pos = $Board.local_to_map(get_global_mouse_position())
	
	if is_dragging_camera:
		ignore_click = true
	
	#Draw preview
	if selected_block != null:
		if action == BoardAction.PLAYER_BULLDOZER:
			block_handler.draw_block_with_tile_id(selected_block, board_pos, LEGAL_PLACEMENT_TILE_ID, SELECTION_LAYER)
		elif action != BoardAction.NONE:
			var id = LEGAL_PLACEMENT_TILE_ID if block_handler.can_place_block(selected_block, BLOCK_LAYER, board_pos) else ILLEGAL_PLACEMENT_TILE_ID
			block_handler.draw_block_with_tile_id(selected_block, board_pos, id, SELECTION_LAYER)

func _input(event):
	var board_pos = $Board.local_to_map(get_global_mouse_position())
	if Input.is_action_just_pressed("load"):
		util.p("testing gameboard with random blocks for turrettesting","bodo")
		select_block(Stats.getRandomBlock(1),func (va):print("done"));
		
	if not event is InputEventMouseMotion and ignore_click: #Ignore the next click
		ignore_click = false
		return
	
	if event.is_action_released("left_click"):
		match action:
			BoardAction.PLAYER_BUILD:
				if block_handler.can_place_block(selected_block, BLOCK_LAYER, board_pos):
					_place_block(selected_block, board_pos)
					_action_finished(true)
			
			BoardAction.PLAYER_MOVE:
				if selected_block == null:
					var block = block_handler.get_block_from_board(board_pos, BLOCK_LAYER, EXTENSION_LAYER, true)
					block_handler.remove_block_from_board(block, board_pos, BLOCK_LAYER, EXTENSION_LAYER)
					selected_block = block
					moved_from_position = board_pos #Save block information in case the user interrupts the process
					moved_from_block = selected_block.clone()

				elif block_handler.can_place_block(selected_block, BLOCK_LAYER, board_pos):
					_place_block(selected_block, board_pos)
					_action_finished(true)
					
			BoardAction.PLAYER_BULLDOZER:
				block_handler.remove_block_from_board(selected_block, board_pos, BLOCK_LAYER, EXTENSION_LAYER)
				_action_finished(true)
				
		_spawn_turrets()
	
	if event.is_action_released("right_click"):
		if selected_block != null:
			block_handler.rotate_block(selected_block)
	
	if event.is_action_released("interrupt"):
		_action_finished(false)


func _place_block(block: Block, position: Vector2):
	var data = $Board.get_cell_tile_data(BLOCK_LAYER, position)
	if data != null: #There is already a piece -> upgrade
		var level = data.get_custom_data("level")
		block_handler.set_block_level(block, level + 1)

	block_handler.draw_block(block, position, BLOCK_LAYER, EXTENSION_LAYER)

func _action_finished(finished: bool):
	if not finished and moved_from_block != null: #Restore block if there is something to restore
		block_handler.draw_block(moved_from_block, moved_from_position, BLOCK_LAYER, EXTENSION_LAYER)
		_spawn_turrets()
	selected_block = null
	moved_from_block = null
	moved_from_position = Vector2.ZERO
	action = BoardAction.NONE
	done.call(finished)
	done = Callable() #Reset callable

func _draw_walls():
	for row in Stats.board_height:
		$Board.set_cell(BLOCK_LAYER, Vector2(0,row), WALL_TILE_ID, Vector2(0,0))
		$Board.set_cell(BLOCK_LAYER, Vector2(Stats.board_width-1,row), WALL_TILE_ID, Vector2(0,0))
	
	for col in Stats.board_width:
		$Board.set_cell(BLOCK_LAYER, Vector2(col,0), WALL_TILE_ID, Vector2(0,0))
		$Board.set_cell(BLOCK_LAYER, Vector2(col,Stats.board_height-1), WALL_TILE_ID, Vector2(0,0))
		
func _spawn_turrets():
	_remove_turrets()
	for row in range(1,Stats.board_height-1):
		for col in range(1,Stats.board_width-1):
			var block_data = $Board.get_cell_tile_data(BLOCK_LAYER, Vector2(col, row))
			var extension_data = $Board.get_cell_tile_data(EXTENSION_LAYER, Vector2(col, row))
			if block_data != null:
				var color = block_data.get_custom_data("color").to_upper()
				if color == "WALL" or color == "GREY":
					continue
				var level = block_data.get_custom_data("level")
				var extension = extension_data.get_custom_data("extension").to_upper()
				var turret = Turret.create(Stats.TurretColor.get(color), level, Stats.TurretExtension.get(extension))
				turret.position = $Board.map_to_local(Vector2(col, row))
				add_child(turret)
				
func _remove_turrets():
	for child in get_children():
		if child is Turret:
			child.queue_free()
			
func dragging_camera(is_dragging: bool):
	self.is_dragging_camera = is_dragging
