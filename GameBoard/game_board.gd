extends Node2D
class_name GameBoard
var selected_block = null

var moved_from_position = Vector2.ZERO #As (0,0) will be part of the wall, it is outside of bounds and can be treated as not initialized
var moved_from_block = null

@export var gameState:GameState
@onready var block_handler:BlockHandler = BlockHandler.new($Board)
enum BoardAction {NONE=0, PLAYER_BUILD=1, PLAYER_MOVE=2, PLAYER_BULLDOZER=3}
var action: BoardAction = BoardAction.NONE
var done: Callable

var turret_holder = util.TurretHolder.new()

var main_spawner

var preview_turrets = null
var highlighted_turrets = []

const BLOCK_LAYER = 0
const GROUND_LAYER = 1
const EXTENSION_LAYER = 2
const SELECTION_LAYER = 3
const CATASTROPHY_LAYER = 4

var is_dragging_camera = false
var is_moving_camera = false
var ignore_click = false

var is_delayed = false
var delay_timer: Timer

const LEGAL_PLACEMENT_TILE_ID = 1
const ILLEGAL_PLACEMENT_TILE_ID = 2
const WALL_TILE_ID = 3
const PREVIEW_BLOCK_TILE_ID = 4
const EMPTY_TILE_ID = 6
const SPAWNER_TILE_ID = 2
const CATASTROPHY_PREVIEW_TILE_ID = 2

var navigation_polygon = NavigationPolygon.new()
var points = PackedVector2Array([Vector2(),Vector2(),Vector2(),Vector2()])

func _ready():
	randomize()
	print("board initiated")
	$Board.tile_set.tile_size = Vector2(Stats.block_size, Stats.block_size)
	navigation_polygon.source_geometry_group_name = "navigation"
	$Board.add_to_group("navigation")
	navigation_polygon.source_geometry_mode = NavigationPolygon.SOURCE_GEOMETRY_GROUPS_WITH_CHILDREN
	navigation_polygon.agent_radius = 26
	
	delay_timer = Timer.new()
	delay_timer.autostart = false
	delay_timer.one_shot = true
	delay_timer.wait_time = Stats.CARD_PLACEMENT_DELAY
	delay_timer.timeout.connect(func(): is_delayed = false)
	add_child(delay_timer)
	gameState.getCamera().is_dragging_camera.connect(dragging_camera)
	
	_set_navigation_region()
	pass
func start_bulldozer(done:Callable, size_x:int, size_y:int):
	util.p("Bulldozering stuff now...", "Jojo")
	is_delayed = true
	delay_timer.start()
	var pieces = []
	for row in size_y:
		for col in size_x:
			pieces.push_back(Block.Piece.new(Vector2(-col, -row), Stats.TurretColor.GREY, -1)) #Color has no particular reason
	selected_block = Block.new(pieces)
	action = BoardAction.PLAYER_BULLDOZER
	self.done = done
	
func start_move(done:Callable):
	util.p("Moving stuff now...", "Jojo")
	is_delayed = true
	delay_timer.start()
	action = BoardAction.PLAYER_MOVE
	self.done = done

func select_piece(shape:Stats.BlockShape, color:Stats.TurretColor, done:Callable, level:int, extension:Stats.TurretExtension=Stats.TurretExtension.DEFAULT):
	util.p("Building now...", "Jojo")
	is_delayed = true
	delay_timer.start()
	util.p(Stats.getStringFromEnumExtension(extension))
	action = BoardAction.PLAYER_BUILD
	selected_block = Stats.getBlockFromShape(shape, color, level)
	self.done = done

func select_block(block,done:Callable):
	util.p("Building now...", "Jojo")
	is_delayed = true
	delay_timer.start()
	action = BoardAction.PLAYER_BUILD
	selected_block = block
	self.done = done
	
func BULLDOZER_catastrophy(done: Callable):
	util.p("Bulldozer catastrophe starting", "Jojo")
	var row = randi_range(1, gameState.board_height-1-Stats.bulldozer_catastrophy_height)
	gameState.getCamera().move_to($Board.map_to_local(Vector2(gameState.board_width/2, row)), func():
		self.done = done
		var distance = block_handler.get_board_distance_at_row(BLOCK_LAYER, row)
		var col = randi_range(distance.from, distance.to-Stats.bulldozer_catastrophy_width)
		var pieces = []
		for y in Stats.bulldozer_catastrophy_height:
			for x in Stats.bulldozer_catastrophy_width:
				#No constructor overloading in Godot, gotta init some nonsense
				pieces.push_back(Block.Piece.new(Vector2(x,y), Stats.TurretColor.BLUE, 1))
		
		var block = Block.new(pieces)
		block_handler.draw_block_with_tile_id(block, Vector2(col, row), CATASTROPHY_PREVIEW_TILE_ID, CATASTROPHY_LAYER)
		get_tree().create_timer(Stats.CATASTROPHY_PREVIEW_DURATION).timeout.connect(func():
			$Board.clear_layer(CATASTROPHY_LAYER)
			var explosion_position = $Board.map_to_local(Vector2(col + Stats.bulldozer_catastrophy_width/2, row + Stats.bulldozer_catastrophy_height/2))
			var explosion_scale = max(Stats.bulldozer_catastrophy_height/2, Stats.bulldozer_catastrophy_width/2)
			Explosion.create(0, 0, explosion_position, self, explosion_scale)
			gameState.getCamera().shake(1.5, 10,explosion_position)
			block_handler.remove_block_from_board(block, Vector2(col, row), BLOCK_LAYER, EXTENSION_LAYER, false)
			_remove_turrets(block, Vector2(col, row))
			_action_finished(true)
			)
	)

func DRILL_catastrophy(done: Callable):
	util.p("Drill catastrophe starting", "Jojo")
	self.done = done
	var row = randi_range(1, gameState.board_height-1-Stats.drill_catastrophy_width)
	gameState.getCamera().move_to($Board.map_to_local(Vector2(gameState.board_width/2, row)), func():
		var pieces = []
		for r in Stats.drill_catastrophy_width:
			var distance = block_handler.get_board_distance_at_row(BLOCK_LAYER, row+r)
			for col in range(distance.from, distance.to+1):
				pieces.push_back(Block.Piece.new(Vector2(col, row+r), Stats.TurretColor.BLUE, 1))
		var block = Block.new(pieces)
		block_handler.draw_block_with_tile_id(block, Vector2(0, 0), CATASTROPHY_PREVIEW_TILE_ID, CATASTROPHY_LAYER)
		get_tree().create_timer(Stats.CATASTROPHY_PREVIEW_DURATION).timeout.connect(func():
			$Board.clear_layer(CATASTROPHY_LAYER)
			var delay=0;
			gameState.getCamera().shake(block.pieces.size()*0.05+1, 5,block.pieces[0].position)
			for piece in block.pieces:
				delay=delay+0.05
				get_tree().create_timer(delay).timeout.connect(func():
					Explosion.create(0, 0, $Board.map_to_local(piece.position), self, 0.5)
					block_handler.remove_block_from_board(Block.new([piece]), Vector2(0, 0), BLOCK_LAYER, EXTENSION_LAYER, false)
					_remove_turrets(Block.new([piece]), Vector2(0, 0))
					)
					
			_action_finished(true)
			)
		)

func LEVELDOWN_catastrophy(done: Callable):
	util.p("Level down catastrophy starting", "Jojo")
	self.done = done
	var row = randi_range(1, gameState.board_height-1-Stats.level_down_catastrophy_height)
	gameState.getCamera().move_to($Board.map_to_local(Vector2(gameState.board_width/2, row)), func():
		var distance = block_handler.get_board_distance_at_row(BLOCK_LAYER, row)
		var col = randi_range(distance.from, distance.to-Stats.level_down_catastrophy_width)
		var pieces = []
		var preview_pieces = []
		for y in Stats.level_down_catastrophy_height:
			for x in Stats.level_down_catastrophy_width:
				var piece = block_handler.get_piece_from_board(Vector2(col + x, row + y), BLOCK_LAYER, EXTENSION_LAYER)
				if piece != null:
					piece.position.x = x
					piece.position.y = y
					pieces.append(piece)
				preview_pieces.append(Block.Piece.new(Vector2(x,y), Stats.TurretColor.BLUE, 1))
				
		var block = Block.new(pieces)
		block_handler.draw_block_with_tile_id(Block.new(preview_pieces), Vector2(col, row), CATASTROPHY_PREVIEW_TILE_ID, CATASTROPHY_LAYER)
		get_tree().create_timer(Stats.CATASTROPHY_PREVIEW_DURATION).timeout.connect(func():
			$Board.clear_layer(CATASTROPHY_LAYER)
			_set_block_and_turrets_level(block, Vector2(col, row), 1)
			block_handler.draw_block(block, Vector2(col, row), BLOCK_LAYER, EXTENSION_LAYER)
			_action_finished(true)
			)
	)
	
func COLORCHANGER_catastrophy(done: Callable):
	util.p("Grey maker catastrophy starting", "Jojo")
	self.done = done
	var row = randi_range(1, gameState.board_height-1-Stats.colorchanger_catastrophy_width)
	gameState.getCamera().move_to($Board.map_to_local(Vector2(gameState.board_width/2, row)), func():
		self.done = done
		var distance = block_handler.get_board_distance_at_row(BLOCK_LAYER, row)
		var col = randi_range(distance.from, distance.to-Stats.colorchanger_catastrophy_width)
		var pieces = []
		for y in Stats.colorchanger_catastrophy_height:
			for x in Stats.colorchanger_catastrophy_width:
				pieces.append(Block.Piece.new(Vector2(x,y), Stats.TurretColor.BLUE, 1))
		
		var block = Block.new(pieces)
		block_handler.draw_block_with_tile_id(block, Vector2(col, row), CATASTROPHY_PREVIEW_TILE_ID, CATASTROPHY_LAYER)
		get_tree().create_timer(Stats.CATASTROPHY_PREVIEW_DURATION).timeout.connect(func():
			$Board.clear_layer(CATASTROPHY_LAYER)
			gameState.getCamera().shake(1.5, 10,block.pieces[0].position)
			var positions = []
			for y in Stats.colorchanger_catastrophy_height:
				for x in Stats.colorchanger_catastrophy_width:
					var data = $Board.get_cell_tile_data(BLOCK_LAYER, Vector2(col+x, row+y))
					if data != null and data.get_custom_data("color").to_upper() != "WALL":
						positions.append(Vector2(col+x, row+y))
			
			if positions.size() > 0:
				var change_block = block_handler.get_block_from_board(positions.pick_random(), BLOCK_LAYER, EXTENSION_LAYER, false)
				var new_pieces = []
				for piece in change_block.pieces: new_pieces.append(Block.Piece.new(piece.position, Stats.TurretColor.GREY, 1))
				block_handler.draw_block(Block.new(new_pieces), Vector2(0, 0), BLOCK_LAYER, EXTENSION_LAYER)
				_remove_turrets(Block.new(new_pieces), Vector2(0, 0))
			_action_finished(true)
			)
	)

func _process(_delta):
	$Board.clear_layer(SELECTION_LAYER)
	
	var board_pos = $Board.local_to_map(get_global_mouse_position())
	
	#Highlight towers
	for turret in highlighted_turrets:
		if is_instance_valid(turret):
			turret.de_highlight()
	highlighted_turrets = []
	var block = block_handler.get_block_from_board(board_pos, BLOCK_LAYER, EXTENSION_LAYER, false, false, false)
	if block != null:
		for piece in block.pieces:
			var turret = turret_holder.get_turret_at($Board.map_to_local(piece.position))
			if turret != null:
				turret.highlight()
				highlighted_turrets.append(turret)
	
	if is_dragging_camera:
		ignore_click = true
	
	#Draw preview
	if selected_block != null:
		if action == BoardAction.PLAYER_BULLDOZER:
			block_handler.draw_block_with_tile_id(selected_block, board_pos, LEGAL_PLACEMENT_TILE_ID, SELECTION_LAYER)
		elif action != BoardAction.NONE:
			var id = LEGAL_PLACEMENT_TILE_ID if block_handler.can_place_block(selected_block, BLOCK_LAYER, board_pos, $NavigationRegion2D, gameState.spawners) else ILLEGAL_PLACEMENT_TILE_ID
			block_handler.draw_block_with_tile_id(selected_block, board_pos, id, SELECTION_LAYER)
		
		if preview_turrets == null: _load_preview_turrets_from_selected_block()
		if preview_turrets.size() == selected_block.pieces.size():
			var idx = 0
			for piece in selected_block.pieces:
				preview_turrets[idx].position = $Board.map_to_local(Vector2(piece.position.x + board_pos.x, piece.position.y + board_pos.y))
				idx += 1
	
	$NavigationRegion2D.bake_navigation_polygon()

func _input(event):
	var board_pos = $Board.local_to_map(get_global_mouse_position())
	
	if is_delayed:
		return
	
	if not event is InputEventMouseMotion and ignore_click: #Ignore the next click
		ignore_click = false
		return
	
	if event.is_action_released("left_click"):
		match action:
			BoardAction.PLAYER_BUILD:
				if block_handler.can_place_block(selected_block, BLOCK_LAYER, board_pos, $NavigationRegion2D, gameState.spawners):
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
					if block_handler.can_place_block(selected_block, BLOCK_LAYER, board_pos, $NavigationRegion2D, gameState.spawners):
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
		_set_block_and_turrets_level(block, position, level + 1)
	else:
		_spawn_turrets(block, position)

	block_handler.draw_block(block, position, BLOCK_LAYER, EXTENSION_LAYER)
	$NavigationRegion2D.bake_navigation_polygon()
	
func _action_finished(finished: bool):
	if not finished and moved_from_block != null: #Restore block if there is something to restore
		block_handler.draw_block(moved_from_block, moved_from_position, BLOCK_LAYER, EXTENSION_LAYER)

	selected_block = null
	
	if preview_turrets != null: 
		for turret in preview_turrets: turret.queue_free()
		preview_turrets = null
	
	moved_from_block = null
	moved_from_position = Vector2.ZERO
	action = BoardAction.NONE
	if not done.is_null():
		done.call(finished)
		done = Callable() #Reset callable

func init_field():
	#Redraw walls and ground
	for row in gameState.board_height:
		$Board.set_cell(BLOCK_LAYER, Vector2(0,row), WALL_TILE_ID, Vector2(0,0))
		$Board.set_cell(BLOCK_LAYER, Vector2(gameState.board_width-1,row), WALL_TILE_ID, Vector2(0,0))
		
	for col in gameState.board_width:
		$Board.set_cell(BLOCK_LAYER, Vector2(col,0), WALL_TILE_ID, Vector2(0,0))
		$Board.set_cell(BLOCK_LAYER, Vector2(col,gameState.board_height-1), WALL_TILE_ID, Vector2(0,0))
	
	#Add main spawner
	var spawner_position = Vector2(floor(gameState.board_width/2), gameState.board_height-1)	
	$Board.set_cell(BLOCK_LAYER, spawner_position, -1, Vector2(0,0))
	$Board.set_cell(GROUND_LAYER, spawner_position, SPAWNER_TILE_ID, Vector2(0,0))
	main_spawner = Spawner.create(gameState,  $Board.map_to_local(spawner_position))
	gameState.spawners.append(main_spawner)
	
	for row in range(1, gameState.board_height-1):
		for col in range(1, gameState.board_width-1):
			$Board.set_cell(GROUND_LAYER, Vector2(col, row), EMPTY_TILE_ID, Vector2(0,0))
	
	$NavigationRegion2D.bake_navigation_polygon()

func draw_field_from_walls(walls_positions: PackedVector2Array):
	var height = -1
	#Add walls
	for wall_position in walls_positions:
		$Board.set_cell(BLOCK_LAYER, Vector2(wall_position.x,wall_position.y), WALL_TILE_ID, Vector2(0,0))
		height = max(height, wall_position.y)

		#Add ground
	for row in range(1, height):
		var distance = block_handler.get_board_distance_at_row(BLOCK_LAYER, row)
		for col in range(distance.from, distance.to+1):
			$Board.set_cell(GROUND_LAYER, Vector2(col, row), EMPTY_TILE_ID, Vector2(0,0))
	
	#Add spawners
	for spawner in gameState.spawners:
		Spawner.create(gameState, spawner.position)
		$Board.set_cell(BLOCK_LAYER, $Board.local_to_map(spawner.position), -1, Vector2(0,0))
		$Board.set_cell(GROUND_LAYER, $Board.local_to_map(spawner.position), SPAWNER_TILE_ID, Vector2(0,0))
		if main_spawner == null or main_spawner.position.y < spawner.position.y:
			main_spawner = spawner
func start_extension(done:Callable):
	extend_field(done)
	done.call()#debug, so my stuff works
	pass;
func extend_field(done:Callable):
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
	
	#Move spawner
	$Board.set_cell(GROUND_LAYER, $Board.local_to_map(main_spawner.position), EMPTY_TILE_ID, Vector2(0,0))
	var spawner_position = Vector2(floor(gameState.board_width/2), gameState.board_height+Stats.board_extend_height-1)
	$Board.set_cell(BLOCK_LAYER, spawner_position, -1, Vector2(0,0))
	$Board.set_cell(GROUND_LAYER, spawner_position, SPAWNER_TILE_ID, Vector2(0,0))
	main_spawner.position = $Board.map_to_local(spawner_position)
	
	#Add spawners left and right
	var add_spawner_left = randi_range(1, 100) <= Stats.board_cave_spawner_chance_percent
	var add_spawner_right = randi_range(1, 100) <= Stats.board_cave_spawner_chance_percent
	if generate_cave_left and add_spawner_left: add_spawner_to_side_wall(randi_range(gameState.board_height+1, gameState.board_height + Stats.board_extend_height - 3), false)
	if generate_cave_right and add_spawner_right: add_spawner_to_side_wall(randi_range(gameState.board_height+1, gameState.board_height + Stats.board_extend_height - 3), true)
	
	gameState.board_height += Stats.board_extend_height
	_set_navigation_region()
	
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
		
		#Make sure the walls dont extend the max deepness
		if right_side and curr_col >= gameState.board_width + Stats.board_cave_deepness.to - 1 and rand_dir == 1: rand_dir = -1
		if not right_side and curr_col <= -Stats.board_cave_deepness.to and rand_dir == -1: rand_dir = 1
		
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

func add_spawner_to_side_wall(row: int, right_side: bool):
	var distance = block_handler.get_board_distance_at_row(BLOCK_LAYER, row)
	var col = distance.to + 1 if right_side else distance.from - 1
	$Board.set_cell(BLOCK_LAYER, Vector2(col, row), -1, Vector2(0,0))
	$Board.set_cell(GROUND_LAYER, Vector2(col, row), SPAWNER_TILE_ID, Vector2(0,0))
	#Add wall to the left/right
	if right_side: $Board.set_cell(BLOCK_LAYER, Vector2(col+1, row), WALL_TILE_ID, Vector2(0,0))
	else: $Board.set_cell(BLOCK_LAYER, Vector2(col-1, row), WALL_TILE_ID, Vector2(0,0))
	var spawner = Spawner.create(gameState, $Board.map_to_local(Vector2(col, row)),10)
	gameState.spawners.append(spawner)

func _spawn_turrets(block: Block, position: Vector2):
	for piece in block.pieces:
		if piece.color != Stats.TurretColor.GREY:
			var turret = Turret.create(piece.color, piece.level, piece.extension)
			turret.position = $Board.map_to_local(Vector2(position.x + piece.position.x, position.y + piece.position.y))
			add_child(turret)
			turret_holder.insert_turret(turret)
			

func _remove_turrets(block: Block, position: Vector2):
	for piece in block.pieces:
		var pos = $Board.map_to_local(Vector2(position.x + piece.position.x, position.y + piece.position.y))
		var turret = turret_holder.pop_turret_at(pos)
		if turret != null:
			turret.queue_free()

func _set_block_and_turrets_level(block: Block, position: Vector2, level: int):
	block_handler.set_block_level(block, level)
	for piece in block.pieces:
		var pos = $Board.map_to_local(Vector2(position.x + piece.position.x, position.y + piece.position.y))
		var turret = turret_holder.get_turret_at(pos)
		if turret != null:
			if block.extension!=null:turret.extension=block.extension
			turret.levelup(level)

func _load_preview_turrets_from_selected_block():
	preview_turrets = []
	for piece in selected_block.pieces:
		if piece.color != Stats.TurretColor.GREY:
			var turret = Turret.create(piece.color, piece.level, piece.extension)
			#turret.get_node("EnemyDetector").visible=true
			turret.placed=false
			add_child(turret)
			preview_turrets.append(turret)

func _spawn_all_turrets():
	_remove_all_turrets()
	for row in range(1,gameState.board_height-1):
		var distance = block_handler.get_board_distance_at_row(BLOCK_LAYER, row)
		for col in range(distance.from, distance.to+1):
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
	points[0] = Vector2(-Stats.board_cave_deepness.to * Stats.block_size,0)
	points[1] = Vector2((gameState.board_width + Stats.board_cave_deepness.to)  * Stats.block_size,0)
	points[2] = Vector2((gameState.board_width + Stats.board_cave_deepness.to) * Stats.block_size,gameState.board_height * Stats.block_size)
	points[3] = Vector2(-Stats.board_cave_deepness.to * Stats.block_size,gameState.board_height * Stats.block_size)
	
	navigation_polygon.add_outline(points) #add the Vector array to create the outline for the polygon
	$NavigationRegion2D.set_navigation_polygon(navigation_polygon) #add the  Polygon to the Navigation Region
	$NavigationRegion2D.bake_navigation_polygon() #create the area inside the outlines
	

func dragging_camera(is_dragging: bool):
	self.is_dragging_camera = is_dragging
