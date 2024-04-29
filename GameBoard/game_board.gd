extends Node2D
class_name GameBoard
var selected_block = null

var moved_from_position = Vector2.ZERO #As (0,0) will be part of the wall, it is outside of bounds and can be treated as not initialized
var moved_from_block = null

var spawners 
@export var gameState:GameState
@onready var block_handler:BlockHandler = BlockHandler.new($Board)
enum BoardAction {NONE=0, PLAYER_BUILD=1, PLAYER_MOVE=2, PLAYER_BULLDOZER=3}
var action: BoardAction = BoardAction.NONE
var done: Callable

var turret_holder = util.TurretHolder.new()

const BLOCK_LAYER = 0
const GROUND_LAYER = 1
const EXTENSION_LAYER = 2
const SELECTION_LAYER = 3

var is_dragging_camera = false
var ignore_click = false

const LEGAL_PLACEMENT_TILE_ID = 1
const ILLEGAL_PLACEMENT_TILE_ID = 2
const WALL_TILE_ID = 3
const PREVIEW_BLOCK_TILE_ID = 4
const EMPTY_TILE_ID = 6

var navigation_polygon = NavigationPolygon.new()
var points = PackedVector2Array([Vector2(),Vector2(),Vector2(),Vector2()])

func _ready():
	gameState=GameState.gameState
	$Board.tile_set.tile_size = Vector2(Stats.block_size, Stats.block_size)
	navigation_polygon.source_geometry_group_name = "navigation"
	$Board.add_to_group("navigation")
	navigation_polygon.source_geometry_mode = NavigationPolygon.SOURCE_GEOMETRY_GROUPS_WITH_CHILDREN
	navigation_polygon.agent_radius = 31
	spawners = get_tree().get_nodes_in_group("spawner")
	
	$Camera2D.is_dragging_camera.connect(dragging_camera)
	_set_navigation_region()

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
	util.p(Stats.getStringFromEnumExtension(extension))
	action = BoardAction.PLAYER_BUILD
	selected_block = Stats.getBlockFromShape(shape, color, level)
	self.done = done

func select_block(block,done:Callable):
	util.p("Building now...", "Jojo")
	action = BoardAction.PLAYER_BUILD
	selected_block = block
	self.done = done
	
func BULLDOZER_catastrophy(done: Callable):
	util.p("Bulldozer catastrophe starting", "Jojo")
	self.done = done
	var row = randi_range(1, gameState.board_height-1-Stats.bulldozer_catastrophy_height)
	var width = block_handler.get_board_width_range(BLOCK_LAYER, row)
	var col = randi_range(width.from, width.to-Stats.bulldozer_catastrophy_width)
	var pieces = []
	for y in Stats.bulldozer_catastrophy_height:
		for x in Stats.bulldozer_catastrophy_width:
			#No constructor overloading in Godot, gotta init some nonsense
			pieces.push_back(Block.Piece.new(Vector2(x,y), Stats.TurretColor.BLUE, 1))
	var block = Block.new(pieces)
	block_handler.remove_block_from_board(block, Vector2(col, row), BLOCK_LAYER, EXTENSION_LAYER, false)
	_remove_turrets(block, Vector2(col, row))
	_action_finished(true)
	
func DRILL_catastrophy(done: Callable):
	util.p("Drill catastrophe starting", "Jojo")
	self.done = done
	var row = randi_range(1, gameState.board_height-1-Stats.drill_catastrophy_width)
	var pieces = []
	
	for r in Stats.drill_catastrophy_width:
		var width = block_handler.get_board_width_range(BLOCK_LAYER, row+r)
		for col in range(width.from, width.to+1):
			pieces.push_back(Block.Piece.new(Vector2(col, row+r), Stats.TurretColor.BLUE, 1))
	var block = Block.new(pieces)
	block_handler.remove_block_from_board(block, Vector2(0, 0), BLOCK_LAYER, EXTENSION_LAYER, false)
	_remove_turrets(block, Vector2(0, 0))
	_action_finished(true)

func LEVELDOWN_catastrophy(done: Callable):
	util.p("Level down catastrophy starting", "Jojo")
	self.done = done
	var start = Vector2(randi_range(1, gameState.board_width-1-Stats.level_down_catastrophy_width), randi_range(1, gameState.board_height-1-Stats.level_down_catastrophy_height))
	var row = randi_range(1, gameState.board_height-1-Stats.bulldozer_catastrophy_height)
	var width = block_handler.get_board_width_range(BLOCK_LAYER, row)
	var col = randi_range(width.from, width.to-Stats.bulldozer_catastrophy_width)
	var pieces = []
	for y in Stats.level_down_catastrophy_height:
		for x in Stats.level_down_catastrophy_width:
			var piece = block_handler.get_piece_from_board(Vector2(col + x, row + y), BLOCK_LAYER, EXTENSION_LAYER)
			if piece != null:
				piece.position.x = x
				piece.position.y = y
				pieces.append(piece)
			
	var block = Block.new(pieces)
	block_handler.set_block_level(block, 1)
	block_handler.draw_block(block, start, BLOCK_LAYER, EXTENSION_LAYER)
	_remove_turrets(block, start)
	_spawn_turrets(block, start)
	_action_finished(true)
	
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
			var id = LEGAL_PLACEMENT_TILE_ID if block_handler.can_place_block(selected_block, BLOCK_LAYER, board_pos, $NavigationRegion2D, spawners) else ILLEGAL_PLACEMENT_TILE_ID
			block_handler.draw_block_with_tile_id(selected_block, board_pos, id, SELECTION_LAYER)
	
func _input(event):
	var board_pos = $Board.local_to_map(get_global_mouse_position())
	
		
	if not event is InputEventMouseMotion and ignore_click: #Ignore the next click
		ignore_click = false
		return
	
	if event.is_action_released("left_click"):
		match action:
			BoardAction.PLAYER_BUILD:
				if block_handler.can_place_block(selected_block, BLOCK_LAYER, board_pos, $NavigationRegion2D, spawners):
					_place_block(selected_block, board_pos)
					_action_finished(true)
			
			BoardAction.PLAYER_MOVE:
				if selected_block == null:
					var block = block_handler.get_block_from_board(board_pos, BLOCK_LAYER, EXTENSION_LAYER, true)
					if block.pieces.size() == 0: #If no block got selected (nothing found at the clicked pos), ignore
						return
					block_handler.remove_block_from_board(block, board_pos, BLOCK_LAYER, EXTENSION_LAYER, false)
					selected_block = block
					moved_from_position = board_pos #Save block information in case the user interrupts the process
					moved_from_block = selected_block.clone()
					_remove_turrets(selected_block, board_pos)

				else:
					if block_handler.can_place_block(selected_block, BLOCK_LAYER, board_pos, $NavigationRegion2D, spawners):
						_place_block(selected_block, board_pos)
						_action_finished(true)
					
			BoardAction.PLAYER_BULLDOZER:
				block_handler.remove_block_from_board(selected_block, board_pos, BLOCK_LAYER, EXTENSION_LAYER, false)
				_remove_turrets(selected_block, board_pos)
				_action_finished(true)
				$NavigationRegion2D.bake_navigation_polygon()
				
	
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
		_remove_turrets(block, position)

	block_handler.draw_block(block, position, BLOCK_LAYER, EXTENSION_LAYER)
	_spawn_turrets(block, position)
	$NavigationRegion2D.bake_navigation_polygon()
	
func _action_finished(finished: bool):
	if not finished and moved_from_block != null: #Restore block if there is something to restore
		block_handler.draw_block(moved_from_block, moved_from_position, BLOCK_LAYER, EXTENSION_LAYER)

	selected_block = null
	moved_from_block = null
	moved_from_position = Vector2.ZERO
	action = BoardAction.NONE
	if not done.is_null():
		done.call(finished)
		done = Callable() #Reset callable

func draw_field():
	clear_field()
	#Redraw walls and ground
	for row in gameState.board_height:
		$Board.set_cell(BLOCK_LAYER, Vector2(0,row), WALL_TILE_ID, Vector2(0,0))
		$Board.set_cell(BLOCK_LAYER, Vector2(gameState.board_width-1,row), WALL_TILE_ID, Vector2(0,0))
		
	for col in gameState.board_width:
		$Board.set_cell(BLOCK_LAYER, Vector2(col,0), WALL_TILE_ID, Vector2(0,0))
		$Board.set_cell(BLOCK_LAYER, Vector2(col,gameState.board_height-1), WALL_TILE_ID, Vector2(0,0))
	
	for row in range(1, gameState.board_height-1):
		for col in range(1, gameState.board_width-1):
			$Board.set_cell(GROUND_LAYER, Vector2(col, row), EMPTY_TILE_ID, Vector2(0,0))
		
	$NavigationRegion2D.bake_navigation_polygon()

func clear_field():
	var index = 0
	var width
	var height
	while($Board.get_cell_tile_data(BLOCK_LAYER, Vector2(0, index)) != null): index += 1
	height = index
	index = 0
	while($Board.get_cell_tile_data(BLOCK_LAYER, Vector2(index, 0)) != null): index += 1
	width = index

	for row in height:
		$Board.set_cell(BLOCK_LAYER, Vector2(0, row), -1, Vector2(0,0))
		$Board.set_cell(BLOCK_LAYER, Vector2(width-1, row), -1, Vector2(0,0))
		
	for col in width:
		$Board.set_cell(BLOCK_LAYER, Vector2(col,0), -1, Vector2(0,0))
		$Board.set_cell(BLOCK_LAYER, Vector2(col, height-1), -1, Vector2(0,0))
		
	$Board.clear_layer(GROUND_LAYER)
	
func extend_field():
	#Clear bottom row
	for col in gameState.board_width:
		$Board.set_cell(BLOCK_LAYER, Vector2(col, gameState.board_height-1), -1, Vector2(0,0))
	
	var generate_cave_left = randi_range(0, 100) <= Stats.board_cave_chance_percent
	var generate_cave_right = randi_range(0, 100) <= Stats.board_cave_chance_percent
	
	if generate_cave_left: generate_cave(gameState.board_height-1, Stats.board_extend_height, false)
	if generate_cave_right: generate_cave(gameState.board_height-1, Stats.board_extend_height, true)
		
	#Extend everything that is not a cave
	for row in Stats.board_extend_height:
		if not generate_cave_left:
			$Board.set_cell(BLOCK_LAYER, Vector2(0, row+gameState.board_height-1), WALL_TILE_ID, Vector2(0,0))
		if not generate_cave_right:
			$Board.set_cell(BLOCK_LAYER, Vector2(gameState.board_width-1, row+gameState.board_height-1), WALL_TILE_ID, Vector2(0,0))
	
	#Draw the ground
	for row in Stats.board_extend_height:
		var col = 0
		while $Board.get_cell_source_id(BLOCK_LAYER, Vector2(col, row+gameState.board_height-1)) == -1:
			$Board.set_cell(GROUND_LAYER, Vector2(col, row+gameState.board_height-1), EMPTY_TILE_ID, Vector2(0,0))
			col -= 1
		col = 1
		while $Board.get_cell_source_id(BLOCK_LAYER, Vector2(col, row+gameState.board_height-1)) == -1:
			$Board.set_cell(GROUND_LAYER, Vector2(col, row+gameState.board_height-1), EMPTY_TILE_ID, Vector2(0,0))
			col += 1
	
	#Add bottom row
	for col in gameState.board_width:
		$Board.set_cell(BLOCK_LAYER, Vector2(col, gameState.board_height+Stats.board_extend_height-1), WALL_TILE_ID, Vector2(0,0))
	
	gameState.board_height += Stats.board_extend_height
	
func generate_cave(pos_y: int, height: int, right_side: bool):
	#Draw top line
	var start_width = randi_range(Stats.board_cave_deepness.from, Stats.board_cave_deepness.to)
	for col in start_width:
		if right_side: $Board.set_cell(BLOCK_LAYER, Vector2(gameState.board_width+col-1, pos_y), WALL_TILE_ID, Vector2(0,0))
		else: $Board.set_cell(BLOCK_LAYER, Vector2(-col, pos_y), WALL_TILE_ID, Vector2(0,0))
	
	#Draw random structure
	var curr_col = gameState.board_width+start_width-1 if right_side else -start_width+1
	for row in height-1:
		$Board.set_cell(BLOCK_LAYER, Vector2(curr_col, pos_y+row), WALL_TILE_ID, Vector2(0,0))
		var rand_dir = randi_range(-1, 1) #-1 is left, 0 do nothing, 1 is right
		#Make sure the walls dont move to much towards the middle
		if right_side and curr_col <= gameState.board_width and rand_dir == -1: rand_dir = 1
		if not right_side and curr_col >= -1 and rand_dir == 1: rand_dir = -1 
		
		curr_col += rand_dir
		$Board.set_cell(BLOCK_LAYER, Vector2(curr_col, pos_y+row), WALL_TILE_ID, Vector2(0,0))
	
	#Draw bottom line
	if right_side:
		while curr_col >= gameState.board_width-1:
			$Board.set_cell(BLOCK_LAYER, Vector2(curr_col, pos_y+height-1), WALL_TILE_ID, Vector2(0,0))
			curr_col -= 1
	else:
		while curr_col <= 0:
			$Board.set_cell(BLOCK_LAYER, Vector2(curr_col, pos_y+height-1), WALL_TILE_ID, Vector2(0,0))
			curr_col += 1

func _spawn_turrets(block: Block, position: Vector2):
	for piece in block.pieces:
		if piece.color != Stats.TurretColor.GREY:
			var turret = Turret.create(piece.color, piece.level, piece.extension)
			add_child(turret)
			turret.position = $Board.map_to_local(Vector2(position.x + piece.position.x, position.y + piece.position.y))
			if piece.level > 1:
				turret.levelup(piece.level)
			turret_holder.insert_turret(turret)
			

func _remove_turrets(block: Block, position: Vector2):
	for piece in block.pieces:
		var pos = $Board.map_to_local(Vector2(position.x + piece.position.x, position.y + piece.position.y))
		var turret = turret_holder.pop_turret_at(pos)
		if turret != null:
			turret.queue_free()

func bake_nav():
	
	pass;
	
func _spawn_all_turrets():
	_remove_all_turrets()
	for row in range(1,gameState.board_height-1):
		var width = block_handler.get_board_width_range(BLOCK_LAYER, row)
		for col in range(width.from, width.to+1):
			var block_data = $Board.get_cell_tile_data(BLOCK_LAYER, Vector2(col, row))
			var id = $Board.get_cell_source_id(BLOCK_LAYER, Vector2(col, row))
			var extension_data = $Board.get_cell_tile_data(EXTENSION_LAYER, Vector2(col, row))
			if block_data != null and id != PREVIEW_BLOCK_TILE_ID:
				var color = block_data.get_custom_data("color").to_upper()
				if color == "WALL" or color == "GREY":
					return
				var level = block_data.get_custom_data("level")
				var extension = extension_data.get_custom_data("extension").to_upper()
				var turret = Turret.create(Stats.TurretColor.get(color), level, Stats.TurretExtension.get(extension))
				turret.position = $Board.map_to_local(Vector2(col, row))
				add_child(turret)
			
func _remove_all_turrets():
	for child in get_children():
		if child is Turret:
			child.queue_free()


func _set_navigation_region():
	navigation_polygon.clear()
	#Create 4 Vectors for the 4 corners
	points[0] = Vector2(0,0)
	points[1] = Vector2(gameState.board_width * Stats.block_size,0)
	points[2] = Vector2(gameState.board_width * Stats.block_size,gameState.board_height * Stats.block_size)
	points[3] = Vector2(0,gameState.board_height * Stats.block_size)
	
	navigation_polygon.add_outline(points) #add the Vector array to create the outline for the polygon
	$NavigationRegion2D.set_navigation_polygon(navigation_polygon) #add the  Polygon to the Navigation Region
	$NavigationRegion2D.bake_navigation_polygon() #create the area inside the outlines
	

func dragging_camera(is_dragging: bool):
	self.is_dragging_camera = is_dragging
