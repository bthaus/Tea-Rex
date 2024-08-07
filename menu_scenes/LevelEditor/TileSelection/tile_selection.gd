extends TabContainer
class_name TileSelection

@onready var tile_set = load("res://TileSets/game_board_tileset.tres")

@onready var all_container = $All/AllContainer
@onready var ground_container = $Ground/GroundContainer
@onready var build_container = $Build/BuildContainer
@onready var block_container = $Block/BlockContainer

var all_tile_items: Array[TileItem] = [
	#SPECIAL ENTITIES
	TileItem.new(GameboardConstants.PLAYER_BASE_GREEN_TILE_ID, GameboardConstants.MapLayer.BLOCK_LAYER, "Player Base"),
	TileItem.new(GameboardConstants.SPAWNER_GREEN_TILE_ID, GameboardConstants.MapLayer.BLOCK_LAYER, "Spawner"),
	TileItem.new(GameboardConstants.PORTAL_TILE_ID, GameboardConstants.MapLayer.BLOCK_LAYER, "Portal"),
]

signal tile_selected

func _ready():
	var nodes = EntityFactory.get_all()
	for node in nodes:
		var item = TileItem.new(node.tile_id, node.map_layer, node.name)
		all_tile_items.append(item)
	
	for item in all_tile_items:
		_add_tile_to_container(all_container, item)
		match(item.map_layer):
			GameboardConstants.MapLayer.GROUND_LAYER: _add_tile_to_container(ground_container, item)
			GameboardConstants.MapLayer.BUILD_LAYER: _add_tile_to_container(build_container, item)
			GameboardConstants.MapLayer.BLOCK_LAYER: _add_tile_to_container(block_container, item)


func _add_tile_to_container(container: GridContainer, tile_item: TileItem):
	var atlas: TileSetAtlasSource = tile_set.get_source(tile_item.tile_id)
	var item = load("res://menu_scenes/LevelEditor/TileSelection/tile_selection_item.tscn").instantiate()
	item.set_tile(tile_item, atlas.texture)
	item.clicked.connect(_on_tile_selected)
	container.add_child(item)

func _on_tile_selected(sender, tile_item: TileItem):
	for container in get_children():
		for item in container.get_child(0).get_children():
			item.set_selected(false)
	sender.set_selected(true)
	tile_selected.emit(tile_item)

class TileItem:
	var tile_id: int
	var map_layer: GameboardConstants.MapLayer
	var name: String
	
	func _init(tile_id: int, map_layer: GameboardConstants.MapLayer, name: String):
		self.tile_id = tile_id
		self.map_layer = map_layer
		self.name = name
