extends Node2D

@onready var _selection_tile_container = $HUD/TileScrollContainer/TileGridContainer
@onready var wave_settings = $HUD/WaveSettings


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
	_init_selection_tiles()

#We can use unhandled input here, so that when clicking on a (hud) button the drawing wont trigger
func _unhandled_input(event):
	var board_pos = $Board.local_to_map(get_global_mouse_position())
	if event.is_action_released("left_click"):
		if _get_tile_type(selected_tile_id) == GameboardConstants.GROUND_TYPE:
			$Board.set_cell(GameboardConstants.GROUND_LAYER, board_pos, selected_tile_id, Vector2(0,0))
		else:
			$Board.set_cell(GameboardConstants.BLOCK_LAYER, board_pos, selected_tile_id, Vector2(0,0))
			$Board.set_cell(GameboardConstants.GROUND_LAYER, board_pos, -1, Vector2(0,0))
	elif event.is_action_released("right_click"):
		$Board.set_cell(GameboardConstants.BLOCK_LAYER, board_pos, -1, Vector2(0,0))
		$Board.set_cell(GameboardConstants.GROUND_LAYER, board_pos, -1, Vector2(0,0))

func _init_selection_tiles():
	for child in _selection_tile_container.get_children(): child.free()
	var tile_set = $Board.tile_set
	for tile_item in _selection_tile_items:
		var atlas: TileSetAtlasSource = tile_set.get_source(tile_item.id)
		var item = load("res://LevelEditor/ContainerItems/tile_selection_item.tscn").instantiate()
		item.set_item(tile_item.id, atlas.texture, tile_item.name)
		item.clicked.connect(_item_selected)
		_selection_tile_container.add_child(item)

func _get_tile_type(id: int):
	if id == -1: return null
	var atlas: TileSetAtlasSource = $Board.tile_set.get_source(id)
	var data = atlas.get_tile_data(Vector2(0,0), 0)
	if data == null: return null
	return data.get_custom_data("type").to_upper()

func _item_selected(id: int):
	selected_tile_id = id

func save_board():
	var entities:Array[BaseDTO] = []
	
	for pos in $Board.get_used_cells(GameboardConstants.BLOCK_LAYER):
		var id = $Board.get_cell_source_id(GameboardConstants.BLOCK_LAYER, pos)
		var type = _get_tile_type(id)
		match(type):
			GameboardConstants.WALL_TYPE: entities.append(TileDTO.new(id, GameboardConstants.BLOCK_LAYER, pos.x, pos.y))
			GameboardConstants.SPAWNER_TYPE: entities.append(SpawnerDTO.new(id, pos.x, pos.y))
			GameboardConstants.PLAYER_BASE_TYPE: entities.append(PlayerBaseDTO.new(id, pos.x, pos.y))
		
	for pos in $Board.get_used_cells(GameboardConstants.GROUND_LAYER):
		var id = $Board.get_cell_source_id(GameboardConstants.GROUND_LAYER, pos)
		entities.append(TileDTO.new(id, GameboardConstants.GROUND_LAYER, pos.x, pos.y))
	
	var map_dto = MapDTO.new(entities)
	map_dto.map_name=$HUD/mapname.text
	var battle_slot_dto=BattleSlotDTO.new()
	battle_slot_dto.amount=2;
	map_dto.battle_slots=battle_slot_dto
	map_dto.save(map_dto.map_name,"","maps")
	#...do something with map_dto

func _on_save_button_pressed():
	save_board()

func _on_wave_settings_button_pressed():
	wave_settings.set_spawner_settings(5)
	wave_settings.show()
	
class TileItem:
	var id: int
	var name: String
	func _init(id: int, name: String):
		self.id = id
		self.name = name
