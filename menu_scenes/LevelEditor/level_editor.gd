extends GameObject2D
class_name LevelEditor

@onready var settings = $Camera2D/HUD/Settings
@onready var wave_settings = $Camera2D/HUD/WaveSettings

@onready var default_build_mode_button = $Camera2D/HUD/BuildModes/DefaultBuildModeButton
@onready var draw_build_mode_button = $Camera2D/HUD/BuildModes/DrawBuildModeButton
@onready var bucket_fill_build_mode_button = $Camera2D/HUD/BuildModes/BucketFillBuildModeButton
@onready var tile_selection = $Camera2D/HUD/TileSelection

@onready var menu = $Camera2D/HUD/Menu
@onready var menu_animation = $Camera2D/HUD/Menu/OpenCloseScaleAnimation
@onready var exit_warning = $Camera2D/HUD/ExitWarning
@onready var exit_warning_animation = $Camera2D/HUD/ExitWarning/OpenCloseScaleAnimation

@onready var board_handler: LevelEditorBoardHandler

var map_name: String

enum BuildMode { DEFAULT, DRAW, BUCKET_FILL }
var _build_mode: BuildMode = BuildMode.DEFAULT

var previous_mouse_position = Vector2(-1, -1)
var previous_board_position = Vector2i(-1, -1)

const default_stylebox = preload("res://Styles/default_button.tres")
const selected_stylebox = preload("res://Styles/selected_button.tres")

var selected_tile: TileSelection.TileItem
var ignore_click = false

var editor_game_state: EditorGameState

func _ready():
	$Board.tile_set.tile_size = Vector2(GameboardConstants.TILE_SIZE, GameboardConstants.TILE_SIZE)
	$Background.tile_set.tile_size = Vector2(GameboardConstants.TILE_SIZE, GameboardConstants.TILE_SIZE)
	GameboardUtils.draw_border($Background)
	
	#Set background lines
	for y in range(0, GameboardConstants.BOARD_HEIGHT):
		for x in range(0, GameboardConstants.BOARD_WIDTH):
			$Background.set_cell(0, Vector2(x,y), 0, Vector2(0,0))
	
	board_handler = LevelEditorBoardHandler.new($Board)
	board_handler.spawner_added.connect(_on_spawner_added)
	board_handler.spawner_removed.connect(_on_spawner_removed)
	board_handler.base_removed.connect(_on_base_removed)
	create_editor_game_state(MapDTO.new())
	
	$Camera2D.dragging_camera.connect(dragging_camera)
	tile_selection.tile_selected.connect(_on_tile_selected)
	
	_set_button_selected(default_build_mode_button, true)
	_set_button_selected(draw_build_mode_button, false)
	_set_button_selected(bucket_fill_build_mode_button, false)
	

func _process(delta):
	#Check if editor has focus
	if _build_mode != BuildMode.DRAW:
		if previous_mouse_position == get_global_mouse_position():
			$Camera2D.disable_dragging(false)
		else:
			$Camera2D.disable_dragging(true)

func create_editor_game_state(map_dto:MapDTO):
	var state = SceneHandler.get_scene_instance(SceneHandler.Scene.MAIN_SCENE)
	state.set_script(load("res://Game/editor_gamestate.gd"))
	editor_game_state=state
	editor_game_state.map_dto=map_dto
	map_dto.treasure_ids.clear()
	
	editor_game_state.board=$Board
	board_handler.editor_game_state = state
	add_child(editor_game_state)
	await editor_game_state.ready


func load_map(map_dto: MapDTO):
	create_editor_game_state(map_dto)
	map_name = map_dto.map_name
	var spawner_entities = []
	for entity in map_dto.entities:
		if is_instance_of(entity, SpawnerDTO):
			spawner_entities.append(entity)
	
	#Insert spawners sorted by index
	board_handler.spawner_map_positions.resize(spawner_entities.size())
	for entity in spawner_entities:
		board_handler.spawner_map_positions[entity.spawner_id] = Vector2(entity.map_x, entity.map_y)
		_on_spawner_added()
	
	settings.load_settings(map_dto)
	wave_settings.set_monster_waves(map_dto.waves)
	wave_settings.update_spawner_waves()
	wave_settings.update_items()


#We can use unhandled input here, so that when clicking on a (hud) button the drawing wont trigger
func _unhandled_input(event):
	previous_mouse_position = get_global_mouse_position()
	
	if InputUtils.is_action_just_released(event, "left_click") and ignore_click: # Ignore the next click
		ignore_click = false
		return

	var board_pos = $Board.local_to_map(get_global_mouse_position())
	
	#Check if we changed our mouse pressed status
	var mouse_just_pressed = InputUtils.is_action_just_pressed(event, "left_click") or InputUtils.is_action_just_pressed(event, "right_click")
	var mouse_just_released = InputUtils.is_action_just_released(event, "left_click") or InputUtils.is_action_just_released(event, "right_click")
	
	#Check if we are at a new tile
	var at_new_tile = true if board_pos != previous_board_position else false
	previous_board_position = board_pos
	
	#Handle draw mode
	if _build_mode == BuildMode.DRAW and (at_new_tile or mouse_just_pressed or mouse_just_released):
		#Input should technically not be used in _input... but it works
		if Input.is_action_pressed("left_click"):
			board_handler.set_cell(selected_tile, board_pos)
		elif Input.is_action_pressed("right_click"):
			board_handler.clear_cell_at_highest_layer(board_pos)
	
	#Handle default and bucket fill mode
	elif InputUtils.is_action_just_released(event, "left_click"):
		if selected_tile == null: return
		match (_build_mode):
			BuildMode.DEFAULT: board_handler.set_cell(selected_tile, board_pos)
			BuildMode.BUCKET_FILL: board_handler.bucket_fill(selected_tile, board_pos)
				
	elif InputUtils.is_action_just_released(event, "right_click"):
		match (_build_mode):
			BuildMode.DEFAULT: board_handler.clear_cell_at_highest_layer(board_pos)
			BuildMode.BUCKET_FILL: board_handler.bucket_fill(null, board_pos)

func _on_tile_selected(tile: TileSelection.TileItem):
	selected_tile = tile

func _on_spawner_added():
	wave_settings.add_spawner_setting()
	_update_spawner_labels()
	_update_spawner_entities()

func _on_spawner_removed(id: int):
	wave_settings.remove_spawner_setting(id)
	_update_spawner_labels()
	_update_spawner_entities()
	
func _on_base_removed(base):
	GameState.gameState.targets.erase(base)

func _update_spawner_labels():
	#this was the method that got lost somehow
	var spawner_map_positions = board_handler.spawner_map_positions
	for child in $SpawnerLabels.get_children(): child.queue_free()
	for i in spawner_map_positions.size():
		var label = Label.new()
		label.text = str(i+1)
		label.add_theme_color_override("font_color", Color.BLACK)
		label.add_theme_font_size_override("font_size", 30)
		label.resized.connect(func(): label.position = $Board.map_to_local(spawner_map_positions[i]) - label.get_rect().size / 2) #Wait until text is set
		$SpawnerLabels.add_child(label)

func _update_spawner_entities():
	var positions = board_handler.spawner_map_positions
	for i in positions.size():
		for spawner in editor_game_state.spawners:
			if spawner.map_position == positions[i]:
				spawner.spawner_id = i

func _save_level():
	var monster_waves = wave_settings.get_monster_waves()
	var settings = settings.get_setting_properties()
	board_handler.save_board(monster_waves, settings, map_name)

func _on_default_build_mode_button_pressed():
	_build_mode = BuildMode.DEFAULT
	_set_button_selected(default_build_mode_button, true)
	_set_button_selected(draw_build_mode_button, false)
	_set_button_selected(bucket_fill_build_mode_button, false)
	$Camera2D.disable_dragging(false)

func _on_draw_build_mode_button_pressed():
	_build_mode = BuildMode.DRAW
	_set_button_selected(default_build_mode_button, false)
	_set_button_selected(draw_build_mode_button, true)
	_set_button_selected(bucket_fill_build_mode_button, false)
	$Camera2D.disable_dragging(true)

func _on_bucket_fill_build_mode_button_pressed():
	_build_mode = BuildMode.BUCKET_FILL
	_set_button_selected(default_build_mode_button, false)
	_set_button_selected(draw_build_mode_button, false)
	_set_button_selected(bucket_fill_build_mode_button, true)
	$Camera2D.disable_dragging(false)

func _on_settings_button_pressed():
	settings.open()

func _on_wave_settings_button_pressed():
	wave_settings.open()

func _set_button_selected(sender, selected: bool):
	var style_box = selected_stylebox if selected else default_stylebox
	sender.add_theme_stylebox_override("normal", style_box)
	sender.add_theme_stylebox_override("hover", style_box)
	sender.add_theme_stylebox_override("pressed", style_box)
	sender.add_theme_stylebox_override("focus", style_box)

func dragging_camera():
	ignore_click = true

func _on_menu_button_pressed(): 
	menu_animation.open()
	
func _on_resume_button_pressed(): 
	menu_animation.close(menu.hide)
	exit_warning_animation.close(exit_warning.hide)
	
func _on_save_button_pressed():
	_save_level()
	menu_animation.close(menu.hide)
	
func _on_save_exit_button_pressed():
	_save_level()
	SceneHandler.change_scene(SceneHandler.get_scene_instance(SceneHandler.Scene.LEVEL_EDITOR_MENU), SceneHandler.TransitionEffect.SWIPE_RIGHT)
	
func _on_exit_button_pressed():
	if not exit_warning.visible:
		exit_warning_animation.open()
	
func _on_warning_exit_button_pressed(): 
	SceneHandler.change_scene(SceneHandler.get_scene_instance(SceneHandler.Scene.LEVEL_EDITOR_MENU), SceneHandler.TransitionEffect.SWIPE_RIGHT)
	
func _on_warning_cancel_button_pressed():
	exit_warning_animation.close(exit_warning.hide)
