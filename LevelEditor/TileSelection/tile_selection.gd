extends TabContainer
class_name TileSelection

@onready var tile_set = load("res://TileSets/game_board_tileset.tres")

var _ground_tile_items: Array[TileItem] = [
	TileItem.new(GameboardConstants.GROUND_TILE_ID, "Ground")
]

var _build_tile_items: Array[TileItem] = [
	TileItem.new(GameboardConstants.BUILD_NONE_TILE_ID, "Build None")
]

var _block_tile_items: Array[TileItem] = [
	TileItem.new(GameboardConstants.WALL_TILE_ID, "Wall"),
	TileItem.new(GameboardConstants.PLAYER_BASE_GREEN_TILE_ID, "Green Base"),
	TileItem.new(GameboardConstants.SPAWNER_GREEN_TILE_ID, "Green Spawner"),
	TileItem.new(GameboardConstants.PORTAL_TILE_ID, "Portal")
]

signal tile_selected

func _ready():
	var all_tile_items: Array[TileItem] = []
	all_tile_items.append_array(_ground_tile_items)
	all_tile_items.append_array(_build_tile_items)
	all_tile_items.append_array(_block_tile_items)
	
	_add_tiles_to_container($All, all_tile_items)
	_add_tiles_to_container($Ground, _ground_tile_items)
	_add_tiles_to_container($Build, _build_tile_items)
	_add_tiles_to_container($Block, _block_tile_items)
	
	
func _add_tiles_to_container(container: GridContainer, tile_items: Array[TileItem]):
	for tile_item in tile_items:
		var atlas: TileSetAtlasSource = tile_set.get_source(tile_item.tile_id)
		var item = load("res://LevelEditor/TileSelection/tile_selection_item.tscn").instantiate()
		item.set_tile(tile_item, atlas.texture)
		item.clicked.connect(_on_tile_selected)
		container.add_child(item)

func _on_tile_selected(sender, tile_item: TileItem):
	for container in get_children():
		for item in container.get_children():
			item.set_selected(false)
	sender.set_selected(true)
	tile_selected.emit(tile_item)

class TileItem:
	var tile_id: int
	var name: String
	
	func _init(tile_id: int, name: String):
		self.tile_id = tile_id
		self.name = name
