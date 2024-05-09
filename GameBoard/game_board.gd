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

static var current_tutorial = null

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
const PREVIEW_BLOCK_TILE_ID = 4
const EMPTY_TILE_ID = 6
const CATASTROPHY_PREVIEW_TILE_ID = 2

const SPAWNER_RIGHT_TILE_ID = 7
const SPAWNER_DOWN_TILE_ID = 8
const SPAWNER_LEFT_TILE_ID = 9

const WALL_UP_TILE_ID = 10
const WALL_RIGHT_TILE_ID = 11
const WALL_DOWN_TILE_ID = 12
const WALL_LEFT_TILE_ID = 13

const WALL_EDGE_LEFT_UP_TILE_ID = 14
const WALL_EDGE_RIGHT_UP_TILE_ID = 15
const WALL_EDGE_RIGHT_DOWN_TILE_ID = 16
const WALL_EDGE_LEFT_DOWN_TILE_ID = 17

const WALL_TUNNEL_LEFT_UP_TILE_ID = 18
const WALL_TUNNEL_RIGHT_UP_TILE_ID = 19
const WALL_TUNNEL_RIGHT_DOWN_TILE_ID = 20
const WALL_TUNNEL_LEFT_DOWN_TILE_ID = 21

var BACKGROUND_RANGE_TILE_IDS = util.Distance.new(0, 2)
var BACKGROUND_FIELD_TILE_ID = 3
var BACKGROUND_STREET_TILE_ID = 4

var navigation_polygon = NavigationPolygon.new()
var points = PackedVector2Array([Vector2(),Vector2(),Vector2(),Vector2()])

func _ready():
	
	randomize()
	print("board initiated")
	$Board.tile_set.tile_size = Vector2(Stats.block_size, Stats.block_size)
	$Background.tile_set.tile_size = Vector2(Stats.block_size, Stats.block_size)
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
	
func start_extension(done:Callable):
	util.p("Extending field now...", "Jojo")
	gameState.getCamera().move_to($Board.map_to_local(Vector2(gameState.board_width/2, gameState.board_height)), func():
		extend_field(done)
		done.call()
	)

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
			get_tree().create_timer(1).timeout.connect(func():
				_action_finished(true)
				)
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
					
			get_tree().create_timer(1).timeout.connect(func():
				_action_finished(true)
				)
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
			get_tree().create_timer(1).timeout.connect(func():
				_action_finished(true)
				)
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
			
			#Draw animation
			var delay=0;
			var rnd_pos = positions.pick_random() if positions.size() > 0 else null
			var count = 0
			for piece in block.pieces:
				delay=delay+0.1
				get_tree().create_timer(delay).timeout.connect(func():
					$Board.clear_layer(CATASTROPHY_LAYER)
					$Board.set_cell(CATASTROPHY_LAYER, Vector2(piece.position.x + col, piece.position.y + row), CATASTROPHY_PREVIEW_TILE_ID, Vector2(0,0))
					)
					
				count += 1
				#Stop at selected position (if found)
				if rnd_pos != null and piece.position.x + col == rnd_pos.x and piece.position.y + row == rnd_pos.y:
					break
			
			#Change to grey if a piece got found
			get_tree().create_timer(0.1*count+1).timeout.connect(func():
				$Board.clear_layer(CATASTROPHY_LAYER)
				if rnd_pos != null:
					var change_block = block_handler.get_block_from_board(rnd_pos, BLOCK_LAYER, EXTENSION_LAYER, false)
					var new_pieces = []
					for piece in change_block.pieces: new_pieces.append(Block.Piece.new(piece.position, Stats.TurretColor.GREY, 1))
					block_handler.draw_block(Block.new(new_pieces), Vector2(0, 0), BLOCK_LAYER, EXTENSION_LAYER)
					_remove_turrets(Block.new(new_pieces), Vector2(0, 0))
				
				get_tree().create_timer(1).timeout.connect(func():
					_action_finished(true)
				)
				)
			)
	)

func _process(_delta):
	$Board.clear_layer(SELECTION_LAYER)
	
	var board_pos = $Board.local_to_map(get_global_mouse_position())
	
	#Highlight towers
	for turret in highlighted_turrets:
		if is_instance_valid(turret):
			turret.de_highlight(_delta)
	highlighted_turrets = []
	var block = block_handler.get_block_from_board(board_pos, BLOCK_LAYER, EXTENSION_LAYER, false, false, false)
	if block != null:
		for piece in block.pieces:
			var turret = turret_holder.get_turret_at($Board.map_to_local(piece.position))
			if turret != null:
				turret.highlight(_delta)
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
#this is a inputstopper flag for tutorials and handhovering
var ignore_input=false;
func _input(event):
	var board_pos = $Board.local_to_map(get_global_mouse_position())
	
	if is_delayed:
		return
	
	if not event is InputEventMouseMotion and ignore_click: #Ignore the next click
		ignore_click = false
		return
	#interrupt and rightclick moved upwards so thats still detectable
	if event.is_action_released("right_click"):
		if selected_block != null:
			block_handler.rotate_block(selected_block)
	
	if event.is_action_released("interrupt"):
		_action_finished(false)
	#this uses the inputstopper flag for tutorials and handhovering
	if ignore_input: return
	
	if event.is_action_released("left_click"):
		if Card.contemplatingInterrupt:return;
		match action:
			BoardAction.PLAYER_BUILD:
				if block_handler.can_place_block(selected_block, BLOCK_LAYER, board_pos, $NavigationRegion2D, gameState.spawners):
					_place_block(selected_block, board_pos)
					_action_finished(true)
				elif current_tutorial != null:
					TutorialHolder.showTutorial(current_tutorial, gameState)
					current_tutorial = null
			
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
					elif current_tutorial != null:
						TutorialHolder.showTutorial(current_tutorial, gameState)
						current_tutorial = null
					
			BoardAction.PLAYER_BULLDOZER:
				block_handler.remove_block_from_board(selected_block, board_pos, BLOCK_LAYER, EXTENSION_LAYER, false)
				_remove_turrets(selected_block, board_pos)
				_action_finished(true)
				$NavigationRegion2D.bake_navigation_polygon()
				

func _place_block(block: Block, position: Vector2):
	var data = $Board.get_cell_tile_data(BLOCK_LAYER, position)
	if data != null: #There is already a piece -> upgrade
		var level = data.get_custom_data("level")
		_set_block_and_turrets_level(block, position, level + 1)
	else:
		_spawn_turrets(block, position)
	#soundMechanic:
	var delay=0;
	var inc=0.25/block.pieces.size()
	for p in block.pieces:
		get_tree().create_timer(delay).timeout.connect(func():Sounds.playFromCamera(gameState,Sounds.placeBlock.pick_random()))
		delay=delay+inc;
		
	block_handler.draw_block(block, position, BLOCK_LAYER, EXTENSION_LAYER)
	$NavigationRegion2D.bake_navigation_polygon()
	
func _action_finished(finished: bool):
	if not finished and moved_from_block != null: #Restore block if there is something to restore
		block_handler.draw_block(moved_from_block, moved_from_position, BLOCK_LAYER, EXTENSION_LAYER)
		_spawn_turrets(moved_from_block, moved_from_position)

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
	#Draw walls
	
	#Edges
	$Board.set_cell(BLOCK_LAYER, Vector2(0,0), WALL_EDGE_LEFT_UP_TILE_ID, Vector2(0,0))
	$Board.set_cell(BLOCK_LAYER, Vector2(gameState.board_width-1,0), WALL_EDGE_RIGHT_UP_TILE_ID, Vector2(0,0))
	$Board.set_cell(BLOCK_LAYER, Vector2(gameState.board_width-1,gameState.board_height-1), WALL_EDGE_RIGHT_DOWN_TILE_ID, Vector2(0,0))
	$Board.set_cell(BLOCK_LAYER, Vector2(0,gameState.board_height-1), WALL_EDGE_LEFT_DOWN_TILE_ID, Vector2(0,0))
	
	#Left and right wall
	for row in range(1, gameState.board_height-1):
		$Board.set_cell(BLOCK_LAYER, Vector2(0,row), WALL_LEFT_TILE_ID, Vector2(0,0))
		$Board.set_cell(BLOCK_LAYER, Vector2(gameState.board_width-1,row), WALL_RIGHT_TILE_ID, Vector2(0,0))
		
	#Top and bottom wall
	for col in range(1, gameState.board_width-1):
		$Board.set_cell(BLOCK_LAYER, Vector2(col,0), WALL_UP_TILE_ID, Vector2(0,0))
		$Board.set_cell(BLOCK_LAYER, Vector2(col,gameState.board_height-1), WALL_DOWN_TILE_ID, Vector2(0,0))
	
	#Draw exit to base
	$Board.set_cell(BLOCK_LAYER, Vector2((gameState.board_width/2)-1, 0), WALL_TUNNEL_LEFT_UP_TILE_ID, Vector2(0,0))
	$Board.set_cell(BLOCK_LAYER, Vector2(gameState.board_width/2, 0), -1, Vector2(0,0))
	$Board.set_cell(BLOCK_LAYER, Vector2((gameState.board_width/2)+1, 0), WALL_TUNNEL_RIGHT_UP_TILE_ID, Vector2(0,0))
	
	#Add main spawner
	var spawner_position = Vector2(floor(gameState.board_width/2), gameState.board_height-1)	
	$Board.set_cell(BLOCK_LAYER, spawner_position, -1, Vector2(0,0))
	$Board.set_cell(GROUND_LAYER, spawner_position, SPAWNER_DOWN_TILE_ID, Vector2(0,0))
	main_spawner = Spawner.create(gameState,  $Board.map_to_local(spawner_position))
	gameState.spawners.append(main_spawner)
	
	_draw_background()
		
	#Draw ground
	for row in range(1, gameState.board_height-1):
		for col in range(1, gameState.board_width-1):
			$Board.set_cell(GROUND_LAYER, Vector2(col, row), EMPTY_TILE_ID, Vector2(0,0))
			$Background.set_cell(0, Vector2(col, row), BACKGROUND_FIELD_TILE_ID, Vector2(0,0))
	
	$NavigationRegion2D.bake_navigation_polygon()

func draw_field_from_walls(walls_positions: PackedVector3Array):
	var height = -1
	#Add walls
	for wall_position in walls_positions:
		$Board.set_cell(BLOCK_LAYER, Vector2(wall_position.x,wall_position.y), wall_position.z, Vector2(0,0))
		height = max(height, wall_position.y)

	_draw_background()
	
	#Add ground
	for row in range(1, height):
		var distance = block_handler.get_board_distance_at_row(BLOCK_LAYER, row)
		for col in range(distance.from, distance.to+1):
			$Board.set_cell(GROUND_LAYER, Vector2(col, row), EMPTY_TILE_ID, Vector2(0,0))
			$Background.set_cell(0, Vector2(col, row), BACKGROUND_FIELD_TILE_ID, Vector2(0,0))

	#Add spawners
	for spawner in gameState.spawners:
		var pos = $Board.local_to_map(spawner.position)
		$Board.set_cell(BLOCK_LAYER, pos, -1, Vector2(0,0))
		var id
		if pos.x <= 0: id = SPAWNER_LEFT_TILE_ID
		elif pos.x >= gameState.board_width-1: id = SPAWNER_RIGHT_TILE_ID
		else: id = SPAWNER_DOWN_TILE_ID
			
		$Board.set_cell(GROUND_LAYER, $Board.local_to_map(spawner.position), id, Vector2(0,0))

		if main_spawner == null or main_spawner.position.y < spawner.position.y:
			main_spawner = spawner
			

func extend_field(done:Callable):
	#Clear bottom row
	for col in gameState.board_width:
		$Board.set_cell(BLOCK_LAYER, Vector2(col, gameState.board_height-1), -1, Vector2(0,0))
	
	var generate_cave_left = randi_range(0, 100) <= Stats.board_cave_chance_percent
	var generate_cave_right = randi_range(0, 100) <= Stats.board_cave_chance_percent
	
	#Only allow a maximum of 1 cave at a time
	if generate_cave_left and generate_cave_right:
		var rnd = randi() % 2 == 0
		generate_cave_left = rnd
		generate_cave_right = not rnd
	
	if generate_cave_left: generate_cave(gameState.board_height-1, Stats.board_extend_height, false)
	if generate_cave_right: generate_cave(gameState.board_height-1, Stats.board_extend_height, true)
		
	#Extend everything that is not a cave
	for row in Stats.board_extend_height:
		if not generate_cave_left:
			$Board.set_cell(BLOCK_LAYER, Vector2(0, row+gameState.board_height-1), WALL_LEFT_TILE_ID, Vector2(0,0))
		if not generate_cave_right:
			$Board.set_cell(BLOCK_LAYER, Vector2(gameState.board_width-1, row+gameState.board_height-1), WALL_RIGHT_TILE_ID, Vector2(0,0))
	
	_extend_background(gameState.background_height, gameState.background_height + Stats.board_extend_height)
		
	#Draw the ground
	for row in Stats.board_extend_height:
		var col = 0
		while $Board.get_cell_source_id(BLOCK_LAYER, Vector2(col, row+gameState.board_height-1)) == -1:
			$Board.set_cell(GROUND_LAYER, Vector2(col, row+gameState.board_height-1), EMPTY_TILE_ID, Vector2(0,0))
			$Background.set_cell(0, Vector2(col, row+gameState.board_height-1), BACKGROUND_FIELD_TILE_ID, Vector2(0,0))
			col -= 1
		col = 1
		while $Board.get_cell_source_id(BLOCK_LAYER, Vector2(col, row+gameState.board_height-1)) == -1:
			$Board.set_cell(GROUND_LAYER, Vector2(col, row+gameState.board_height-1), EMPTY_TILE_ID, Vector2(0,0))
			$Background.set_cell(0, Vector2(col, row+gameState.board_height-1), BACKGROUND_FIELD_TILE_ID, Vector2(0,0))
			col += 1
	
	#Add bottom row
	$Board.set_cell(BLOCK_LAYER, Vector2(0, gameState.board_height+Stats.board_extend_height-1), WALL_EDGE_LEFT_DOWN_TILE_ID, Vector2(0,0))
	for col in range(1, gameState.board_width-1):
		$Board.set_cell(BLOCK_LAYER, Vector2(col, gameState.board_height+Stats.board_extend_height-1), WALL_DOWN_TILE_ID, Vector2(0,0))
	$Board.set_cell(BLOCK_LAYER, Vector2(gameState.board_width-1, gameState.board_height+Stats.board_extend_height-1), WALL_EDGE_RIGHT_DOWN_TILE_ID, Vector2(0,0))
	
	#Move spawner
	$Board.set_cell(GROUND_LAYER, $Board.local_to_map(main_spawner.position), EMPTY_TILE_ID, Vector2(0,0))
	var spawner_position = Vector2(floor(gameState.board_width/2), gameState.board_height+Stats.board_extend_height-1)
	$Board.set_cell(BLOCK_LAYER, spawner_position, -1, Vector2(0,0))
	$Board.set_cell(GROUND_LAYER, spawner_position, SPAWNER_DOWN_TILE_ID, Vector2(0,0))
	main_spawner.position = $Board.map_to_local(spawner_position)
	
	#Add spawners left and right
	var add_spawner_left = randi_range(1, 100) <= Stats.board_cave_spawner_chance_percent
	var add_spawner_right = randi_range(1, 100) <= Stats.board_cave_spawner_chance_percent
	
	#Get possible spawner positions
	var rows_left = []
	var rows_right = []
	for row in range(gameState.board_height+1, gameState.board_height + Stats.board_extend_height - 4):
		var distance = block_handler.get_board_distance_at_row(BLOCK_LAYER, row)
		if $Board.get_cell_source_id(BLOCK_LAYER, Vector2(distance.from-1, row)) == WALL_LEFT_TILE_ID:
			rows_left.append(row)
		if $Board.get_cell_source_id(BLOCK_LAYER, Vector2(distance.to+1, row)) == WALL_RIGHT_TILE_ID:
			rows_right.append(row)
	
	if generate_cave_left and add_spawner_left and rows_left.size() > 0: add_spawner_to_side_wall(rows_left.pick_random(), false)
	if generate_cave_right and add_spawner_right and rows_right.size() > 0: add_spawner_to_side_wall(rows_right.pick_random(), true)
	
	gameState.board_height += Stats.board_extend_height
	gameState.background_height += Stats.board_extend_height
	_set_navigation_region()
	
func generate_cave(pos_y: int, height: int, right_side: bool):
	#var start_width = (Stats.board_cave_deepness.from + Stats.board_cave_deepness.to ) / 2
	var start_width = randi_range(Stats.board_cave_deepness.from, Stats.board_cave_deepness.to - Stats.board_cave_deepness.from) #Dont move too far out, so that the random cave can go deeper
	#Draw corners
	if right_side:
		$Board.set_cell(BLOCK_LAYER, Vector2(gameState.board_width-1, pos_y), WALL_TUNNEL_RIGHT_UP_TILE_ID, Vector2(0,0))
		$Board.set_cell(BLOCK_LAYER, Vector2(gameState.board_width-1+start_width, pos_y), WALL_EDGE_RIGHT_UP_TILE_ID, Vector2(0,0))
	else: 
		$Board.set_cell(BLOCK_LAYER, Vector2(0, pos_y), WALL_TUNNEL_LEFT_UP_TILE_ID, Vector2(0,0))
		$Board.set_cell(BLOCK_LAYER, Vector2(-start_width, pos_y), WALL_EDGE_LEFT_UP_TILE_ID, Vector2(0,0))
	#Draw top line
	for col in range(1, start_width):
		if right_side: $Board.set_cell(BLOCK_LAYER, Vector2(gameState.board_width+col-1, pos_y), WALL_UP_TILE_ID, Vector2(0,0))
		else: $Board.set_cell(BLOCK_LAYER, Vector2(-col, pos_y), WALL_UP_TILE_ID, Vector2(0,0))

	#Draw random structure
	var curr_col = gameState.board_width+start_width-1 if right_side else -start_width
	var last_dir = 1 if right_side else -1
	for row in range(1, height-1):
		var rand_dir #-1 is left, 0 do nothing, 1 is right
		#Avoid "thick" walls with 2 layers
		if last_dir == -1: rand_dir = randi_range(-1, 0)
		elif last_dir == 0: rand_dir = randi_range(-1, 1) 
		else: rand_dir = randi_range(0, 1)
			
		#Make sure the walls dont move to much towards the middle
		if right_side and curr_col <= gameState.board_width and rand_dir == -1: rand_dir = 0
		if not right_side and curr_col >= -1 and rand_dir == 1: rand_dir = 0
		
		#Make sure the walls dont extend the max deepness
		if right_side and curr_col >= gameState.board_width + Stats.board_cave_deepness.to - 1 and rand_dir == 1: rand_dir = 0
		if not right_side and curr_col <= -Stats.board_cave_deepness.to and rand_dir == -1: rand_dir = 0
		
		#Last row
		if row == height-2: rand_dir = 0
		
		last_dir = rand_dir
		
		var first_id
		var second_id
		if right_side:
			if rand_dir == -1: first_id = WALL_EDGE_RIGHT_DOWN_TILE_ID; second_id = WALL_TUNNEL_RIGHT_DOWN_TILE_ID
			if rand_dir == 0: first_id = WALL_RIGHT_TILE_ID
			if rand_dir == 1: first_id = WALL_TUNNEL_RIGHT_UP_TILE_ID; second_id = WALL_EDGE_RIGHT_UP_TILE_ID
		else:
			if rand_dir == -1: first_id = WALL_TUNNEL_LEFT_UP_TILE_ID; second_id = WALL_EDGE_LEFT_UP_TILE_ID
			if rand_dir == 0: first_id = WALL_LEFT_TILE_ID
			if rand_dir == 1: first_id = WALL_EDGE_LEFT_DOWN_TILE_ID; second_id = WALL_TUNNEL_LEFT_DOWN_TILE_ID
		
		$Board.set_cell(BLOCK_LAYER, Vector2(curr_col, pos_y+row), first_id, Vector2(0,0))
		if rand_dir != 0:
			curr_col += rand_dir
			$Board.set_cell(BLOCK_LAYER, Vector2(curr_col, pos_y+row), second_id, Vector2(0,0))
	
	#Draw bottom line
	if right_side:
		$Board.set_cell(BLOCK_LAYER, Vector2(curr_col, pos_y+height-1), WALL_EDGE_RIGHT_DOWN_TILE_ID, Vector2(0,0))
		curr_col -= 1
		while curr_col >= gameState.board_width:
			$Board.set_cell(BLOCK_LAYER, Vector2(curr_col, pos_y+height-1), WALL_DOWN_TILE_ID, Vector2(0,0))
			curr_col -= 1
		$Board.set_cell(BLOCK_LAYER, Vector2(curr_col, pos_y+height-1), WALL_TUNNEL_RIGHT_DOWN_TILE_ID, Vector2(0,0))
	else:
		$Board.set_cell(BLOCK_LAYER, Vector2(curr_col, pos_y+height-1), WALL_EDGE_LEFT_DOWN_TILE_ID, Vector2(0,0))
		curr_col += 1
		while curr_col < 0:
			$Board.set_cell(BLOCK_LAYER, Vector2(curr_col, pos_y+height-1), WALL_DOWN_TILE_ID, Vector2(0,0))
			curr_col += 1
		$Board.set_cell(BLOCK_LAYER, Vector2(curr_col, pos_y+height-1), WALL_TUNNEL_LEFT_DOWN_TILE_ID, Vector2(0,0))

func add_spawner_to_side_wall(row: int, right_side: bool):
	var distance = block_handler.get_board_distance_at_row(BLOCK_LAYER, row)
	var col = distance.to + 1 if right_side else distance.from - 1
	$Board.set_cell(BLOCK_LAYER, Vector2(col, row), -1, Vector2(0,0))
	if right_side: $Board.set_cell(GROUND_LAYER, Vector2(col, row), SPAWNER_RIGHT_TILE_ID, Vector2(0,0))
	else: $Board.set_cell(GROUND_LAYER, Vector2(col, row), SPAWNER_LEFT_TILE_ID, Vector2(0,0))
	#Add wall to the left/right
	if right_side: 
		#$Board.set_cell(BLOCK_LAYER, Vector2(col+1, row-1), WALL_TUNNEL_LEFT_DOWN_TILE_ID, Vector2(0,0))
		$Board.set_cell(BLOCK_LAYER, Vector2(col+1, row), WALL_EDGE_LEFT_DOWN_TILE_ID, Vector2(0,0))
		#$Board.set_cell(BLOCK_LAYER, Vector2(col+1, row+1), WALL_TUNNEL_LEFT_UP_TILE_ID, Vector2(0,0))
	else: 
		#$Board.set_cell(BLOCK_LAYER, Vector2(col-1, row-1), WALL_TUNNEL_RIGHT_DOWN_TILE_ID, Vector2(0,0))
		$Board.set_cell(BLOCK_LAYER, Vector2(col-1, row), WALL_EDGE_RIGHT_DOWN_TILE_ID, Vector2(0,0))
		#$Board.set_cell(BLOCK_LAYER, Vector2(col-1, row+1), WALL_TUNNEL_RIGHT_UP_TILE_ID, Vector2(0,0))
	var spawner = Spawner.create(gameState, $Board.map_to_local(Vector2(col, row)),10)
	gameState.spawners.append(spawner)

func _draw_background():
	randomize()
	for row in range(-1, gameState.background_height):
		for col in range((gameState.board_width/2)-(gameState.background_width/2), (gameState.board_width/2)+gameState.background_width/2):
			if row == -1:
				$Background.set_cell(0, Vector2(col, row), BACKGROUND_STREET_TILE_ID, Vector2(0,0))
				continue
			var id = randi_range(BACKGROUND_RANGE_TILE_IDS.from, BACKGROUND_RANGE_TILE_IDS.to)
			$Background.set_cell(0, Vector2(col, row), id,Vector2(0,0))
			
func _extend_background(old_height: int, new_height: int):
	randomize()
	for row in range(old_height+1, new_height+1):
		for col in range((gameState.board_width/2)-(gameState.background_width/2), (gameState.board_width/2)+gameState.background_width/2):
			var id = randi_range(BACKGROUND_RANGE_TILE_IDS.from, BACKGROUND_RANGE_TILE_IDS.to)
			$Background.set_cell(0, Vector2(col, row), id,Vector2(0,0))

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
	
	
func restoreBaseMap(gameState):
	var oldname=gameState.account
	gameState.account=GameSaver.basegamename
	GameSaver.loadGameMap(gameState)
	gameState.account=oldname
	GameSaver.saveGame(gameState)
	pass;	
func reset():
	var cells=$Board.get_used_cells(2)
	
	var delay=0;
	var increment=5.0/cells.size()
	
	
	for c in cells:
		var p=Block.Piece.new(Vector2(0,0),0,0,0)
		delay=delay+increment
		
		
		get_tree().create_timer(delay).timeout.connect(func():
			
			block_handler.remove_block_from_board(Block.new([p]), c, BLOCK_LAYER, EXTENSION_LAYER, false)
			_remove_turrets(Block.new([p]),c)
			Explosion.create(0,0,$Board.map_to_local(c),self,0.5)
			#gameState.getCamera().shake(0.1,4,c)
			
			if $Board.get_used_cells(2).size()==0:
				
				gameState.menu.showDeathScreen()
				
			)
	pass;
func dragging_camera(is_dragging: bool):
	self.is_dragging_camera = is_dragging
