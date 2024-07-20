extends GameObject2D
class_name LevelEditor

@onready var _selection_tile_container = $HUD/TileScrollContainer/TileGridContainer
@onready var wave_settings = $HUD/WaveSettings

@onready var default_build_mode_button = $HUD/BuildModes/DefaultBuildModeButton
@onready var draw_build_mode_button = $HUD/BuildModes/DrawBuildModeButton
@onready var bucket_fill_build_mode_button = $HUD/BuildModes/BucketFillBuildModeButton

@onready var board_handler = LevelEditorBoardHandler.new($Board)

enum BuildMode { DEFAULT, DRAW, BUCKET_FILL }
var _build_mode: BuildMode = BuildMode.DEFAULT

var previous_board_position = Vector2i(-1, -1)

const default_stylebox = preload("res://LevelEditor/Styles/default_button.tres")
const selected_stylebox = preload("res://LevelEditor/Styles/selected_button.tres")

var _selection_tile_items = [
	TileItem.new(GameboardConstants.WALL_TILE_ID, "Wall", GameboardConstants.BLOCK_LAYER),
	TileItem.new(GameboardConstants.PLAYER_BASE_GREEN_TILE_ID, "Base", GameboardConstants.BLOCK_LAYER),
	TileItem.new(GameboardConstants.SPAWNER_GREEN_TILE_ID, "Spawner", GameboardConstants.BLOCK_LAYER),
	TileItem.new(GameboardConstants.GROUND_TILE_ID, "Ground", GameboardConstants.GROUND_LAYER),
	TileItem.new(GameboardConstants.BUILD_NONE_TILE_ID, "Build None", GameboardConstants.BUILD_LAYER),
	TileItem.new(GameboardConstants.PORTAL_TILE_ID, "Portal", GameboardConstants.BLOCK_LAYER)
	]

var selected_tile: TileItem

func _ready():
	$Board.tile_set.tile_size = Vector2(GameboardConstants.TILE_SIZE, GameboardConstants.TILE_SIZE)
	$Background.tile_set.tile_size = Vector2(GameboardConstants.TILE_SIZE, GameboardConstants.TILE_SIZE)
	_set_background()
	
	board_handler.spawner_added.connect(func(): wave_settings.add_spawner_setting())
	board_handler.spawner_removed.connect(func(id: int): wave_settings.remove_spawner_setting(id))
	
	_init_selection_tiles()
	_set_button_selected(default_build_mode_button, true)
	_set_button_selected(draw_build_mode_button, false)
	_set_button_selected(bucket_fill_build_mode_button, false)

#We can use unhandled input here, so that when clicking on a (hud) button the drawing wont trigger
func _unhandled_input(event):
	var board_pos = $Board.local_to_map(get_global_mouse_position())
	
	#Check if we changed our mouse pressed status
	var mouse_just_pressed = Input.is_action_just_pressed("left_click") or Input.is_action_just_pressed("right_click")
	var mouse_just_released = Input.is_action_just_released("left_click") or Input.is_action_just_released("right_click")
	#Check if we are at a new tile
	var at_new_tile = true if board_pos != previous_board_position else false
	previous_board_position = board_pos
	
	#Handle draw mode
	if _build_mode == BuildMode.DRAW and (at_new_tile or mouse_just_pressed or mouse_just_released):
		if Input.is_action_pressed("left_click"):
			board_handler.set_cell(selected_tile, board_pos)
		elif Input.is_action_pressed("right_click"):
			board_handler.clear_cell_layer(board_pos)
	
	#Handle default and bucket fill mode
	elif Input.is_action_just_released("left_click"):
		if selected_tile == null: return
		match (_build_mode):
			BuildMode.DEFAULT: board_handler.set_cell(selected_tile, board_pos)	
			BuildMode.BUCKET_FILL: board_handler.bucket_fill(selected_tile, board_pos)
				
	elif Input.is_action_just_released("right_click"):
		match (_build_mode):
			BuildMode.DEFAULT: board_handler.clear_cell_layer(board_pos)
			BuildMode.BUCKET_FILL: board_handler.bucket_fill(null, board_pos)


func _init_selection_tiles():
	for child in _selection_tile_container.get_children(): child.free()
	var tile_set = $Board.tile_set
	for tile_item in _selection_tile_items:
		var atlas: TileSetAtlasSource = tile_set.get_source(tile_item.id)
		var item = load("res://LevelEditor/ContainerItems/tile_selection_item.tscn").instantiate()
		item.set_tile(tile_item, atlas.texture)
		item.clicked.connect(_tile_selected)
		_selection_tile_container.add_child(item)

func _tile_selected(sender, tile: TileItem):
	selected_tile = tile
	for item in _selection_tile_container.get_children(): item.set_selected(false)
	sender.set_selected(true)
	
func _on_default_build_mode_button_pressed():
	_build_mode = BuildMode.DEFAULT
	_set_button_selected(default_build_mode_button, true)
	_set_button_selected(draw_build_mode_button, false)
	_set_button_selected(bucket_fill_build_mode_button, false)

func _on_draw_build_mode_button_pressed():
	_build_mode = BuildMode.DRAW
	_set_button_selected(default_build_mode_button, false)
	_set_button_selected(draw_build_mode_button, true)
	_set_button_selected(bucket_fill_build_mode_button, false)

func _on_bucket_fill_build_mode_button_pressed():
	_build_mode = BuildMode.BUCKET_FILL
	_set_button_selected(default_build_mode_button, false)
	_set_button_selected(draw_build_mode_button, false)
	_set_button_selected(bucket_fill_build_mode_button, true)

func _on_save_button_pressed():
	var monster_waves = wave_settings.get_monster_waves()
	board_handler.save_board(monster_waves,$HUD/mapname.text)

func _on_wave_settings_button_pressed():
	wave_settings.show()

func _set_background():
	#Set wall frame
	for y in range(-1, GameboardConstants.BOARD_HEIGHT+1):
		for x in range(-1, GameboardConstants.BOARD_WIDTH+1):
			$Background.set_cell(0, Vector2(x,y), 1, Vector2(0,0))
	
	#Set editor lines
	for y in range(0, GameboardConstants.BOARD_HEIGHT):
		for x in range(0, GameboardConstants.BOARD_WIDTH):
			$Background.set_cell(0, Vector2(x,y), 0, Vector2(0,0))
	

func _set_button_selected(sender, selected: bool):
	var style_box = selected_stylebox if selected else default_stylebox
	sender.add_theme_stylebox_override("normal", style_box)
	sender.add_theme_stylebox_override("hover", style_box)
	sender.add_theme_stylebox_override("pressed", style_box)
	sender.add_theme_stylebox_override("focus", style_box)

class TileItem:
	var id: int
	var name: String
	var layer: int
	func _init(id: int, name: String, layer: int):
		self.id = id
		self.name = name
		self.layer = layer
