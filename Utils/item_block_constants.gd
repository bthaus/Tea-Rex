extends Node
class_name ItemBlockConstants

const GROUND_LAYER = 0
const BLOCK_LAYER = 1
const PREVIEW_LAYER = 2

const GROUND_TILE_ID = 0

const WHITE_TILE_ID = 1
const GREEN_TILE_ID = 2
const RED_TILE_ID = 3
const YELLOW_TILE_ID = 4
const BLUE_TILE_ID = 5
const MAGENTA_TILE_ID = 6

const LEGAL_PLACEMENT_TILE_ID = 7
const ILLEGAL_PLACEMENT_TILE_ID = 8

static func get_color_from_tile(board: TileMap, layer: int, map_position: Vector2):
	var data = board.get_cell_tile_data(layer, map_position)
	if data == null: return null
	return Turret.Hue.get(data.get_custom_data("color").to_upper())
