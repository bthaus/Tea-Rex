extends Node2D
class_name GameBoard
var selected_block = null

var moved_from_position = Vector2.ZERO # As (0,0) will be part of the wall, it is outside of bounds and can be treated as not initialized
var moved_from_block = null

@export var gameState: GameState
@onready var block_handler: BlockHandler = BlockHandler.new($Board)
enum BoardAction {NONE = 0, BUILD = 1, MOVE = 2, BULLDOZER = 3}
var action: BoardAction = BoardAction.NONE
var done: Callable

var turret_holder = util.TurretHolder.new()

static var current_tutorial = null

var preview_turrets = null
var highlighted_turrets = []

const BLOCK_LAYER = 0
const GROUND_LAYER = 1
const EXTENSION_LAYER = 2
const SELECTION_LAYER = 3
const CATASTROPHY_LAYER = 4
const RANGE_PREVIEW_LAYER=5

var is_dragging_camera = false
var is_moving_camera = false
var ignore_click = false

var is_delayed = false
var delay_timer: Timer

const RANGE_PREVIEW_TILE_ID = 0
const LEGAL_PLACEMENT_TILE_ID = 1
const ILLEGAL_PLACEMENT_TILE_ID = 2
const PREVIEW_BLOCK_TILE_ID = 3
const EMPTY_TILE_ID = 4

const PLAYER_BASE_ID = 5
const SPAWNER_ID = 6

const WALL_ID = 7

var navigation_polygon = NavigationPolygon.new()
var points = PackedVector2Array([Vector2(), Vector2(), Vector2(), Vector2()])


#this is a inputstopper flag for tutorials and handhovering
var ignore_input = false;
var previous_preview_pos=Vector2(0,0)
var showTurrets=false;

func _ready():
	randomize()
	$Board.tile_set.tile_size = Vector2(Stats.block_size, Stats.block_size)
	navigation_polygon.source_geometry_group_name = "navigation"
	$Board.add_to_group("navigation")
	navigation_polygon.source_geometry_mode = NavigationPolygon.SOURCE_GEOMETRY_GROUPS_WITH_CHILDREN
	navigation_polygon.agent_radius = 26
	
	delay_timer = Timer.new()
	delay_timer.autostart = false
	delay_timer.one_shot = true
	delay_timer.wait_time = Stats.CARD_PLACEMENT_DELAY
	delay_timer.timeout.connect(func(): is_delayed=false)
	add_child(delay_timer)
	gameState.getCamera().is_dragging_camera.connect(dragging_camera)
	
	_set_navigation_region()
	$NavigationRegion2D.bake_navigation_polygon()
	
func start_bulldozer(done: Callable, size_x: int, size_y: int):
	util.p("Bulldozering stuff now...", "Jojo")
	is_delayed = true
	delay_timer.start()
	var pieces = []
	for row in size_y:
		for col in size_x:
			pieces.push_back(Block.Piece.new(Vector2( - col, -row), Stats.TurretColor.GREY, -1)) # Color has no particular reason
	selected_block = Block.new(pieces)
	action = BoardAction.BULLDOZER
	self.done = done
	
func start_move(done: Callable):
	util.p("Moving stuff now...", "Jojo")
	is_delayed = true
	delay_timer.start()
	action = BoardAction.MOVE
	self.done = done

func select_piece(shape: Stats.BlockShape, color: Stats.TurretColor, done: Callable, level: int, extension: Stats.TurretExtension=Stats.TurretExtension.DEFAULT):
	util.p("Building now...", "Jojo")
	is_delayed = true
	delay_timer.start()
	util.p(Stats.getStringFromEnumExtension(extension))
	action = BoardAction.BUILD
	selected_block = Stats.getBlockFromShape(shape, color, level)
	self.done = done

func select_block(block, done: Callable):
	util.p("Building now...", "Jojo")
	is_delayed = true
	delay_timer.start()
	action = BoardAction.BUILD
	selected_block = block
	self.done = done


func _process(_delta):
	$Board.clear_layer(SELECTION_LAYER)
	
	var board_pos = $Board.local_to_map(get_global_mouse_position())
	
	#Highlight towers
	for turret in highlighted_turrets:
		if is_instance_valid(turret):
			turret.de_highlight(_delta)

	highlighted_turrets = []
	var block # = block_handler.get_block_from_board(board_pos, BLOCK_LAYER, EXTENSION_LAYER, false, false, false)
	
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
		if action == BoardAction.BULLDOZER:
			block_handler.draw_block_with_tile_id(selected_block, board_pos, LEGAL_PLACEMENT_TILE_ID, SELECTION_LAYER)
		elif action != BoardAction.NONE:
			var id = LEGAL_PLACEMENT_TILE_ID if block_handler.can_place_block(selected_block, BLOCK_LAYER, board_pos, $NavigationRegion2D, gameState.spawners) else ILLEGAL_PLACEMENT_TILE_ID		
			showTurrets=id==LEGAL_PLACEMENT_TILE_ID
			block_handler.draw_block_with_tile_id(selected_block, board_pos, id, SELECTION_LAYER)
		
		if preview_turrets == null: _load_preview_turrets_from_selected_block()
		if preview_turrets.size() == selected_block.pieces.size():
			var idx = 0
			clear_range_outline()
			for piece in selected_block.pieces:
				var pos=$Board.map_to_local(Vector2(piece.position.x + board_pos.x, piece.position.y + board_pos.y))
				preview_turrets[idx].position = pos
				preview_turrets[idx].base.visible=showTurrets
				#if previous_preview_pos!=pos:
				preview_turrets[idx].showRangeOutline()
				previous_preview_pos=pos;	
				idx += 1

func _input(event):
	var board_pos = $Board.local_to_map(get_global_mouse_position())
	
	if is_delayed:
		return
	
	if not event is InputEventMouseMotion and ignore_click: # Ignore the next click
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
		
		if Card.contemplatingInterrupt: return ;
		match action:
			BoardAction.BUILD:
				if block_handler.can_place_block(selected_block, BLOCK_LAYER, board_pos, $NavigationRegion2D, gameState.spawners):
					_place_block(selected_block, board_pos)
					_action_finished(true)
				elif current_tutorial != null:
					TutorialHolder.showTutorial(current_tutorial, gameState)
					current_tutorial = null
			
			BoardAction.MOVE:
				if selected_block == null:
					var block = block_handler.get_block_from_board(board_pos, BLOCK_LAYER, EXTENSION_LAYER, true)
					if block.pieces.size() == 0: # If no block got selected (nothing found at the clicked pos), ignore
						return
					block_handler.remove_block_from_board(block, board_pos, BLOCK_LAYER, EXTENSION_LAYER, false)
					selected_block = block
					moved_from_position = board_pos # Save block information in case the user interrupts the process
					moved_from_block = selected_block.clone()
					_remove_turrets(selected_block, board_pos)

				else:
					if block_handler.can_place_block(selected_block, BLOCK_LAYER, board_pos, $NavigationRegion2D, gameState.spawners):
						_place_block(selected_block, board_pos)
						_action_finished(true)
					elif current_tutorial != null:
						TutorialHolder.showTutorial(current_tutorial, gameState)
						current_tutorial = null
					
			BoardAction.BULLDOZER:
				block_handler.remove_block_from_board(selected_block, board_pos, BLOCK_LAYER, EXTENSION_LAYER, false)
				_remove_turrets(selected_block, board_pos)
				_action_finished(true)
				$NavigationRegion2D.bake_navigation_polygon()

func show_outline(pos):
	$Board.set_cell(RANGE_PREVIEW_LAYER, $Board.local_to_map(pos), RANGE_PREVIEW_TILE_ID, Vector2(0,0))

func clear_range_outline():
	$Board.clear_layer(RANGE_PREVIEW_LAYER)

func _place_block(block: Block, position: Vector2):
	var data = $Board.get_cell_tile_data(BLOCK_LAYER, position)
	if data != null: # There is already a piece -> upgrade
		var level = data.get_custom_data("level")
		_set_block_and_turrets_level(block, position, level + 1)
	else:
		_spawn_turrets(block, position)
	#soundMechanic:
	var delay = 0;
	var inc = 0.25 / block.pieces.size()
	for p in block.pieces:
		get_tree().create_timer(delay).timeout.connect(func(): Sounds.playFromCamera(gameState, Sounds.placeBlock.pick_random()))
		delay = delay + inc;
		
	block_handler.draw_block(block, position, BLOCK_LAYER, EXTENSION_LAYER)
	$NavigationRegion2D.bake_navigation_polygon()
	
func _action_finished(finished: bool):
	if not finished and moved_from_block != null: # Restore block if there is something to restore
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
		done = Callable() # Reset callable

func init_field():
	#Draw walls
	
	#Left and right wall
	for row in range(1, gameState.board_height - 1):
		$Board.set_cell(BLOCK_LAYER, Vector2(0, row), WALL_ID, Vector2(0, 0))
		$Board.set_cell(BLOCK_LAYER, Vector2(gameState.board_width - 1, row), WALL_ID, Vector2(0, 0))
		
	for col in range(1, gameState.board_width - 1):
		$Board.set_cell(BLOCK_LAYER, Vector2(col, 0), WALL_ID, Vector2(0, 0))
		$Board.set_cell(BLOCK_LAYER, Vector2(col, gameState.board_height - 1), WALL_ID, Vector2(0, 0))

	#Draw ground
	for row in range(1, gameState.board_height - 1):
		for col in range(1, gameState.board_width - 1):
			$Board.set_cell(GROUND_LAYER, Vector2(col, row), EMPTY_TILE_ID, Vector2(0, 0))
	
	$NavigationRegion2D.bake_navigation_polygon()

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
			if block.extension != null: turret.extension = block.extension
			turret.levelup(level)

func _load_preview_turrets_from_selected_block():
	preview_turrets = []
	for piece in selected_block.pieces:
		if piece.color != Stats.TurretColor.GREY:
			var turret = Turret.create(piece.color, piece.level, piece.extension)
			#turret.get_node("EnemyDetector").visible=true
			turret.placed = false
			add_child(turret)
			preview_turrets.append(turret)

func _set_navigation_region():
	navigation_polygon.clear()
	#Create 4 Vectors for the 4 corners
	points[0] = Vector2( - Stats.board_cave_deepness.to * Stats.block_size, 0)
	points[1] = Vector2((gameState.board_width + Stats.board_cave_deepness.to) * Stats.block_size, 0)
	points[2] = Vector2((gameState.board_width + Stats.board_cave_deepness.to) * Stats.block_size, gameState.board_height * Stats.block_size)
	points[3] = Vector2( - Stats.board_cave_deepness.to * Stats.block_size, gameState.board_height * Stats.block_size)
	
	navigation_polygon.add_outline(points) # add the Vector array to create the outline for the polygon
	$NavigationRegion2D.set_navigation_polygon(navigation_polygon) # add the  Polygon to the Navigation Region
	
	$NavigationRegion2D.bake_navigation_polygon() # create the area inside the outlines
	
func reset():
	var cells = $Board.get_used_cells(2)
	
	var increment = 5.0 / cells.size()
	if cells.size() == 0:
		gameState.menu.showDeathScreen()
	
	for cachecounter in range(cells.size()):
		if cachecounter == cells.size() - 1:
			
			Explosion.pushCache(func():
				var delay=0
				for c in cells:
					var p=Block.Piece.new(Vector2(0, 0), 0, 0, 0)
					delay=delay + increment
					print(delay)
					
					create_tween().tween_callback(func():
						
						block_handler.remove_block_from_board(Block.new([p]), c, BLOCK_LAYER, EXTENSION_LAYER, false)
						_remove_turrets(Block.new([p]), c)
						Explosion.create(0, 0, $Board.map_to_local(c), self, 0.5)
						#gameState.getCamera().shake(0.1,4,c)
						
						if $Board.get_used_cells(2).size() == 0:
							
							gameState.menu.showDeathScreen()
							
						).set_delay(delay))
		
		else: Explosion.pushCache(func(): )
	
	pass ;
func dragging_camera(is_dragging: bool):
	self.is_dragging_camera = is_dragging
