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

static func turret_color_to_tile_color(color: Turret.Hue):
	return TileColor.get(Turret.Hue.keys()[color])

static func tile_to_dto(tile_id: int) -> EntityDTO:
	match (tile_id):
		#SPECIAL ENTITIES
		PLAYER_BASE_GREEN_TILE_ID: return PlayerBaseDTO.new(PLAYER_BASE_GREEN_TILE_ID, MapLayer.BLOCK_LAYER, TileColor.GREEN)
		SPAWNER_GREEN_TILE_ID: return SpawnerDTO.new(SPAWNER_GREEN_TILE_ID, MapLayer.BLOCK_LAYER, -1, TileColor.GREEN)
		PORTAL_TILE_ID: return PortalDTO.new(PORTAL_TILE_ID)
		BUILD_NONE_TILE_ID: return BuildDTO.new(BUILD_NONE_TILE_ID, MapLayer.BUILD_LAYER, TileColor.NONE)
		
		_: return EntityDTO.new(tile_id)

	return null
