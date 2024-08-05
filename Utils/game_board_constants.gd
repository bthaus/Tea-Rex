extends GameObjectCounted

class_name GameboardConstants

#BOARD PROPERTIES
const BOARD_WIDTH = 32
const BOARD_HEIGHT = 32
const TILE_SIZE = 62



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
const PORTAL_TILE_ID = 9

const TURRET_BASE_WHITE_TILE_ID = 101
const TURRET_BASE_GREEN_TILE_ID = 201
const TURRET_BASE_RED_TILE_ID = 301
const TURRET_BASE_YELLOW_TILE_ID = 401
const TURRET_BASE_BLUE_TILE_ID = 501
const TURRET_BASE_MAGENTA_TILE_ID = 601

#BUILD
const BUILD_NONE_TILE_ID = 8

#LAYERS
enum MapLayer { GROUND_LAYER = 0, BUILD_LAYER = 1, BLOCK_LAYER = 2, PREVIEW_LAYER = 3 }

#COLORS
enum TileColor { NONE, RED, GREEN, BLUE, YELLOW, WHITE, MAGENTA };

#TYPES
enum TileType { WALL, GROUND, TURRET_BASE, SPAWNER, PLAYER_BASE, PREVIEW, BUILD, PORTAL }

static func get_tile_type(board: TileMap, layer: int, map_position: Vector2):
	var data = board.get_cell_tile_data(layer, map_position)
	if data == null: return null
	var type = TileType.get(data.get_custom_data("type").to_upper())
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
	
static func turret_color_to_tile_color(color: Turret.Hue):
	return TileColor.get(Turret.Hue.keys()[color])


static func tile_to_dto(tile_id: int) -> BaseDTO:
	match (tile_id):
		#GROUND
		GROUND_TILE_ID: return TileDTO.new(GameboardConstants.GROUND_TILE_ID, GameboardConstants.MapLayer.GROUND_LAYER)
		
		#BUILD
		BUILD_NONE_TILE_ID: return TileDTO.new(GameboardConstants.BUILD_NONE_TILE_ID, GameboardConstants.MapLayer.BUILD_LAYER)
		
		#ENTITIES
		PLAYER_BASE_GREEN_TILE_ID: return PlayerBaseDTO.new(GameboardConstants.PLAYER_BASE_GREEN_TILE_ID, GameboardConstants.MapLayer.BLOCK_LAYER, GameboardConstants.TileColor.GREEN)
		SPAWNER_GREEN_TILE_ID: return SpawnerDTO.new(GameboardConstants.SPAWNER_GREEN_TILE_ID, GameboardConstants.MapLayer.BLOCK_LAYER, -1, GameboardConstants.TileColor.GREEN)
		WALL_TILE_ID: return TileDTO.new(GameboardConstants.WALL_TILE_ID, GameboardConstants.MapLayer.BLOCK_LAYER,1,1,true)
		PORTAL_TILE_ID: return PortalDTO.new(GameboardConstants.PORTAL_TILE_ID, GameboardConstants.MapLayer.BLOCK_LAYER)
		
		TURRET_BASE_WHITE_TILE_ID: return TileDTO.new(GameboardConstants.TURRET_BASE_WHITE_TILE_ID, GameboardConstants.MapLayer.BLOCK_LAYER)
		TURRET_BASE_BLUE_TILE_ID: return TileDTO.new(GameboardConstants.TURRET_BASE_BLUE_TILE_ID, GameboardConstants.MapLayer.BLOCK_LAYER)
		TURRET_BASE_RED_TILE_ID: return TileDTO.new(GameboardConstants.TURRET_BASE_RED_TILE_ID, GameboardConstants.MapLayer.BLOCK_LAYER)
		TURRET_BASE_GREEN_TILE_ID: return TileDTO.new(GameboardConstants.TURRET_BASE_GREEN_TILE_ID, GameboardConstants.MapLayer.BLOCK_LAYER)
		TURRET_BASE_YELLOW_TILE_ID: return TileDTO.new(GameboardConstants.TURRET_BASE_YELLOW_TILE_ID, GameboardConstants.MapLayer.BLOCK_LAYER)
		TURRET_BASE_MAGENTA_TILE_ID: return TileDTO.new(GameboardConstants.TURRET_BASE_MAGENTA_TILE_ID, GameboardConstants.MapLayer.BLOCK_LAYER)

	return null
