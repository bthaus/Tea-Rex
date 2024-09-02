extends GameObject2D
class_name GameBoard
var selected_block = null

var moved_from_position = Vector2.ZERO # As (0,0) will be part of the wall, it is outside of bounds and can be treated as not initialized
var moved_from_block = null

@export var gameState: GameState
enum BoardAction {NONE = 0, BUILD = 1, MOVE = 2, BULLDOZER = 3}
var action: BoardAction = BoardAction.NONE
var done: Callable

var block_handler: BlockHandler

static var current_tutorial = null

var preview_turrets = null

var ignore_click = false
var is_delayed = false
var delay_timer: Timer

var previous_mouse_pos = Vector2(0,0)
var points = PackedVector2Array([Vector2(), Vector2(), Vector2(), Vector2()])


#this is a inputstopper flag for tutorials and handhovering
var ignore_input = false;
var previous_preview_pos=Vector2(0,0)

func _ready():
	gameState=GameState.gameState
	randomize()
	$Board.tile_set.tile_size = Vector2(GameboardConstants.TILE_SIZE, GameboardConstants.TILE_SIZE)
	
	block_handler = BlockHandler.new($Board)
	
	delay_timer = Timer.new()
	delay_timer.autostart = false
	delay_timer.one_shot = true
	delay_timer.wait_time = GameplayConstants.CARD_PLACEMENT_DELAY
	delay_timer.timeout.connect(func(): is_delayed=false)
	add_child(delay_timer)
	gameState.getCamera().dragging_camera.connect(dragging_camera)
	
func start_bulldozer(done: Callable, size_x: int, size_y: int):
	util.p("Bulldozering stuff now...", "Jojo")
	is_delayed = true
	delay_timer.start()
	var pieces = []
	for row in size_y:
		for col in size_x:
			pieces.push_back(Block.Piece.new(Vector2( - col, -row), Turret.Hue.WHITE, -1)) # Color has no particular reason
	selected_block = Block.new(pieces)
	action = BoardAction.BULLDOZER
	self.done = done
	
func start_move(done: Callable):
	util.p("Moving stuff now...", "Jojo")
	is_delayed = true
	delay_timer.start()
	action = BoardAction.MOVE
	self.done = done

func select_piece(shape: Block.BlockShape, color: Turret.Hue, done: Callable, level: int, extension: Turret.Extension=Turret.Extension.DEFAULT):
	is_delayed = true
	delay_timer.start()
	action = BoardAction.BUILD
	selected_block = BlockUtils.get_block_from_shape(shape, color, level)
	self.done = done

func select_block(block, done: Callable):
	is_delayed = true
	delay_timer.start()
	action = BoardAction.BUILD
	selected_block = block
	self.done = done


func _input(event):
	var board_pos = $Board.local_to_map(get_global_mouse_position())
	check_mouse_cell_traversal(board_pos)
		
	if is_delayed:
		return
	
	if InputUtils.is_action_just_released(event, "left_click") and ignore_click: # Ignore the next click
		ignore_click = false
		return
		
	#interrupt and rightclick moved upwards so thats still detectable
	if InputUtils.is_action_just_released(event, "right_click"):
		if selected_block != null:
			block_handler.rotate_block(selected_block)
			_draw_selected_block_preview(board_pos)
	
	if InputUtils.is_action_just_released(event, "interrupt"):
		_action_finished(false)
	#this uses the inputstopper flag for tutorials and handhovering
	if ignore_input: return
	
	if InputUtils.is_action_just_released(event, "left_click"):
		if Card.contemplatingInterrupt: return
		match action:
			BoardAction.BUILD:
				if block_handler.can_place_block(selected_block, board_pos,  gameState.spawners):
					_place_block(selected_block, board_pos)
					previous_mouse_pos = Vector2(-1000, -1000) #Pfusch
					_action_finished(true)
				elif current_tutorial != null:
					TutorialHolder.showTutorial(current_tutorial, gameState)
					current_tutorial = null
			
			BoardAction.NONE:
				var block = block_handler.get_block_from_board(board_pos, true)
				if block==null or block.pieces.size() == 0: # If no block got selected (nothing found at the clicked pos), ignore
					return
				block_handler.remove_block_from_board(block, board_pos)
				selected_block = block
				moved_from_position = board_pos # Save block information in case the user interrupts the process
				moved_from_block = selected_block.clone()
				action = BoardAction.BUILD
				_remove_turrets(selected_block, board_pos)
				previous_mouse_pos = Vector2(-1000, -1000) #Pfusch
				
			BoardAction.BULLDOZER:
				block_handler.remove_block_from_board(selected_block, board_pos)
				_remove_turrets(selected_block, board_pos)
				_action_finished(true)
				

func check_mouse_cell_traversal(map_position: Vector2):
	if map_position!=previous_mouse_pos:
		var turret_or_not_to_unhover=GameState.gameState.collisionReference.get_turret_from_board(previous_mouse_pos)
		if turret_or_not_to_unhover!=null:
			turret_or_not_to_unhover.on_unhover()
		var turret_or_not=GameState.gameState.collisionReference.get_turret_from_board(map_position)
		if turret_or_not!=null:
			turret_or_not.on_hover()
		
		_draw_selected_block_preview(map_position)
		previous_mouse_pos=map_position

func _draw_selected_block_preview(map_position: Vector2):
	#Draw preview
	if selected_block != null:
		$Board.clear_layer(GameboardConstants.MapLayer.PREVIEW_LAYER)
		var can_place_block = false
		if action == BoardAction.BULLDOZER:
			block_handler.draw_block_with_tile_id(selected_block, map_position, GameboardConstants.LEGAL_PLACEMENT_TILE_ID, GameboardConstants.MapLayer.PREVIEW_LAYER)
		elif action != BoardAction.NONE:
			can_place_block = block_handler.can_place_block(selected_block, map_position,  gameState.spawners)
			
		#Draw range preview first
		if preview_turrets == null: _load_preview_turrets_from_selected_block()
		if preview_turrets.size() == selected_block.pieces.size():
			var idx = 0
			clear_range_outline()
			for piece in selected_block.pieces:
				var pos = $Board.map_to_local(map_position + piece.position)
				preview_turrets[idx].position = pos
				preview_turrets[idx].base.visible = can_place_block
				preview_turrets[idx].base.showRangeOutline()
				previous_preview_pos = pos;
				idx += 1
		Spawner.refresh_all_paths()	
		#update estimated damage
		Spawner.update_damage_estimate()
		#Draw actual block shape
		var id = GameboardConstants.LEGAL_PLACEMENT_TILE_ID if can_place_block else GameboardConstants.ILLEGAL_PLACEMENT_TILE_ID
		block_handler.draw_block_with_tile_id(selected_block, map_position, id, GameboardConstants.MapLayer.PREVIEW_LAYER)

func _place_block(block: Block, map_position: Vector2):
	var piece = block_handler.get_piece_from_board(map_position)
	if piece != null: # There is already a piece -> upgrade
		_upgrade_turrets(block, map_position)
	else:
		_spawn_turrets(block, map_position)
	#soundMechanic:
	var delay = 0;
	var inc = 0.25 / block.pieces.size()
	for p in block.pieces:
		get_tree().create_timer(delay).timeout.connect(func(): Sounds.playFromCamera(gameState, Sounds.placeBlock.pick_random()))
		delay = delay + inc;
		
	block_handler.draw_block(block, map_position)
	
func _action_finished(finished: bool):
	if not finished and moved_from_block != null: # Restore block if there is something to restore
		block_handler.draw_block(moved_from_block, moved_from_position)
		_spawn_turrets(moved_from_block, moved_from_position)

	selected_block = null
	
	if preview_turrets != null:
		for turret in preview_turrets: turret.queue_free()
		preview_turrets = null
	
	moved_from_block = null
	moved_from_position = Vector2.ZERO
	action = BoardAction.NONE
	$Board.clear_layer(GameboardConstants.MapLayer.PREVIEW_LAYER)
	Spawner.refresh_all_paths()
	if not done.is_null():
		done.call(finished)
		done = Callable() # Reset callable

func init_field(map_dto: MapDTO):
	for entity:EntityDTO in map_dto.entities:
		entity.get_object().place_on_board($Board)
	link_spawners_to_waves(map_dto)
	
func link_spawners_to_waves(map_dto):
	Spawner.all_movement_types.clear()
	Spawner.grids.clear()
	Spawner.invisible_grids.clear()
	for spawner in GameState.gameState.spawners:
		for w in map_dto.waves:
			var wave=[]
			for v in w:
				if v.spawner_id==spawner.spawner_id:
					wave.append(v)
					
			spawner.waves.append(wave)
		spawner.initialise()	
			
	pass;
func _spawn_turrets(block: Block, map_position: Vector2):
	for piece in block.pieces:
		#if piece.color != Turret.Hue.WHITE:
		var turret = Turret.create(piece.color, piece.level, piece.extension,true)
		turret.global_position = $Board.map_to_local(map_position + piece.position)
		add_child(turret)


func _remove_turrets(block: Block, map_position: Vector2):
	for piece in block.pieces:
		var turret = GameState.collisionReference.get_turret_from_board(map_position + piece.position)
		if turret != null:
			turret.queue_free()

func _upgrade_turrets(block: Block, map_position: Vector2):
	for piece in block.pieces:
		var turret = GameState.collisionReference.get_turret_from_board(map_position + piece.position)
		if turret != null:
			if block.extension != null: turret.extension = block.extension
			if not turret.is_max_level():
				turret.levelup(turret.base.stacks + 1)

func _load_preview_turrets_from_selected_block():
	preview_turrets = []
	for piece in selected_block.pieces:
		#if piece.color != Turret.Hue.WHITE:
		var turret = Turret.create(piece.color, piece.level, piece.extension)
		add_child(turret)
		preview_turrets.append(turret)


func reset():
	var cells = $Board.get_used_cells(2)
	
	var increment = 5.0 / cells.size()
	if cells.size() == 0:
		gameState.ui.showDeathScreen()
	
	for cachecounter in range(cells.size()):
		if cachecounter == cells.size() - 1:
			
			Explosion.pushCache(func():
				var delay=0
				for c in cells:
					var p=Block.Piece.new(Vector2(0, 0), 0, 0, 0)
					delay=delay + increment
					
					create_tween().tween_callback(func():
						
						block_handler.remove_block_from_board(Block.new([p]), c)
						_remove_turrets(Block.new([p]), c)
						Explosion.create(0, 0, $Board.map_to_local(c), self, 0.5)
						#gameState.getCamera().shake(0.1,4,c)
						
						if $Board.get_used_cells(2).size() == 0:
							
							gameState.ui.showDeathScreen()
							
						).set_delay(delay))
		
		else: Explosion.pushCache(func(): )

func show_outline(pos):
	$Board.set_cell(GameboardConstants.MapLayer.PREVIEW_LAYER, $Board.local_to_map(pos), GameboardConstants.TURRET_RANGE_PREVIEW_TILE_ID, Vector2(0,0))

func clear_range_outline():
	$Board.clear_layer(GameboardConstants.MapLayer.PREVIEW_LAYER)

func register_blocking_color(movement_type:Monster.MonsterMovingType,color:Turret.Hue):
	
	pass;
func increase_max_stacks(color:Turret.Hue,amount:int):
	
	pass;	

func dragging_camera():
	ignore_click = true
