extends GameObjectCounted

class_name GameboardConstants
#LAYERS
const GROUND_LAYER = 0
const BUILD_LAYER = 1
const BLOCK_LAYER = 2
const PREVIEW_LAYER = 3

#HELPER
const TURRET_RANGE_PREVIEW_TILE_ID = 0
const LEGAL_PLACEMENT_TILE_ID = 1
const ILLEGAL_PLACEMENT_TILE_ID = 2
const BASE_PREVIEW_TILE_ID = 3

#GROUND
const GROUND_TILE_ID = 4

#ENTITIES
const PLAYER_BASE_GREEN_TILE_ID = 5
const SPAWNER_GREEN_TILE_ID = 6
const WALL_TILE_ID = 7

#BUILD
const BUILD_ANY_TILE_ID = 8

#COLORS
enum TileColor { ANY, RED, GREEN, BLUE, YELLOW, WHITE };

#TYPES
enum TileType { WALL, GROUND, TURRET_BASE, SPAWNER, PLAYER_BASE, BUILD}

static func get_tile_type(board: TileMap, layer: int, map_position: Vector2):
	var data = board.get_cell_tile_data(layer, map_position)
	if data == null: return null
	var type= TileType.get(data.get_custom_data("type").to_upper())
	return type
	
static func get_tile_type_by_id(board: TileMap, id: int):
	if id == -1: return null
	var atlas: TileSetAtlasSource = board.tile_set.get_source(id)
	var data = atlas.get_tile_data(Vector2(0,0), 0)
	if data == null: return null
	return TileType.get(data.get_custom_data("type").to_upper())
	
static func get_tile_color(board: TileMap, layer: int, map_position: Vector2):
	var data = board.get_cell_tile_data(layer, map_position)
	if data == null: return null
	return TileColor.get(data.get_custom_data("color").to_upper())
