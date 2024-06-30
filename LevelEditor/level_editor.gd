extends Node2D

@onready var _selection_tile_container = $HUD/TileScrollContainer/TileGridContainer
var _selection_tile_items = [
	TileItem.new(GameboardConstants.WALL_TILE_ID, "Wall"),
	TileItem.new(GameboardConstants.PLAYER_BASE_TILE_ID, "Base"),
	TileItem.new(GameboardConstants.SPAWNER_TILE_ID, "Spawner")
	]

var selected_tile_id = -1

func _ready():
	$Board.tile_set.tile_size = Vector2(Stats.block_size, Stats.block_size)
	_init_selection_tiles()

#We can use unhandled input here, so that when clicking on a (hud) button the drawing wont trigger
func _unhandled_input(event):
	var board_pos = $Board.local_to_map(get_global_mouse_position())
	if event.is_action_released("left_click"):
		$Board.set_cell(GameboardConstants.BLOCK_LAYER, board_pos, selected_tile_id, Vector2(0,0))
	elif event.is_action_released("right_click"):
		$Board.set_cell(GameboardConstants.BLOCK_LAYER, board_pos, -1, Vector2(0,0))

func _init_selection_tiles():
	for child in _selection_tile_container.get_children(): child.free()
	var tile_set = $Board.tile_set
	for tile_item in _selection_tile_items:
		var atlas: TileSetAtlasSource = tile_set.get_source(tile_item.id)
		var item = load("res://LevelEditor/tile_selection_item.tscn").instantiate()
		item.set_item(tile_item.id, atlas.texture, tile_item.name)
		item.clicked.connect(_item_selected)
		_selection_tile_container.add_child(item)

func _item_selected(id: int):
	selected_tile_id = id

class TileItem:
	var id: int
	var name: String
	func _init(id: int, name: String):
		self.id = id
		self.name = name
