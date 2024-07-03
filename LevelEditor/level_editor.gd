extends Node2D

@onready var _selection_tile_container = $HUD/TileScrollContainer/TileGridContainer
@onready var wave_settings = $HUD/WaveSettings

@onready var board_handler = LevelEditorBoardHandler.new($Board)

var _selection_tile_items = [
	TileItem.new(GameboardConstants.WALL_TILE_ID, "Wall"),
	TileItem.new(GameboardConstants.PLAYER_BASE_TILE_ID, "Base"),
	TileItem.new(GameboardConstants.SPAWNER_TILE_ID, "Spawner"),
	TileItem.new(GameboardConstants.GROUND_TILE_ID, "Ground")
	]

var selected_tile_id = -1

func _ready():
	$Board.tile_set.tile_size = Vector2(Stats.block_size, Stats.block_size)
	$Background.tile_set.tile_size = Vector2(Stats.block_size, Stats.block_size)
	for y in range(-200, 200):
		for x in range(-200, 200):
			$Background.set_cell(0, Vector2(x,y), 0, Vector2(0,0))
	
	board_handler.spawner_added.connect(func(): wave_settings.add_spawner_setting())
	board_handler.spawner_removed.connect(func(id: int): wave_settings.remove_spawner_setting(id))
	
	_init_selection_tiles()

#We can use unhandled input here, so that when clicking on a (hud) button the drawing wont trigger
func _unhandled_input(event):
	var board_pos = $Board.local_to_map(get_global_mouse_position())
	if event.is_action_released("left_click"):
		board_handler.set_cell(selected_tile_id, board_pos)
	elif event.is_action_released("right_click"):
		board_handler.clear_cell(board_pos)
	
func _init_selection_tiles():
	for child in _selection_tile_container.get_children(): child.free()
	var tile_set = $Board.tile_set
	for tile_item in _selection_tile_items:
		var atlas: TileSetAtlasSource = tile_set.get_source(tile_item.id)
		var item = load("res://LevelEditor/ContainerItems/tile_selection_item.tscn").instantiate()
		item.set_item(tile_item.id, atlas.texture, tile_item.name)
		item.clicked.connect(_item_selected)
		_selection_tile_container.add_child(item)

func _item_selected(id: int):
	selected_tile_id = id

func _on_save_button_pressed():
	var monster_waves = wave_settings.get_monster_waves()
	board_handler.save_board(monster_waves)

func _on_wave_settings_button_pressed():
	wave_settings.show()
	
class TileItem:
	var id: int
	var name: String
	func _init(id: int, name: String):
		self.id = id
		self.name = name
