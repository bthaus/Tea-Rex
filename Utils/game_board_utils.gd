extends Node
class_name GameboardUtils

static func turret_color_to_tile_color(color: Turret.Hue):
	return GameboardConstants.TileColor.get(Turret.Hue.keys()[color])

static func local_to_map_on_scaled_board(board: TileMap, local_position: Vector2) -> Vector2:
	return board.local_to_map((local_position - board.position) / board.scale)

static func draw_border(board: TileMap):
	for y in range(-1, GameboardConstants.BOARD_HEIGHT+1):
		board.set_cell(GameboardConstants.MapLayer.BLOCK_LAYER, Vector2(-1, y), GameboardConstants.WALL_TILE_ID, Vector2(0,0))
		board.set_cell(GameboardConstants.MapLayer.BLOCK_LAYER, Vector2(GameboardConstants.BOARD_WIDTH, y), GameboardConstants.WALL_TILE_ID, Vector2(0,0))

	for x in range(-1, GameboardConstants.BOARD_WIDTH+1):
		board.set_cell(GameboardConstants.MapLayer.BLOCK_LAYER, Vector2(x, -1), GameboardConstants.WALL_TILE_ID, Vector2(0,0))
		board.set_cell(GameboardConstants.MapLayer.BLOCK_LAYER, Vector2(x, GameboardConstants.BOARD_HEIGHT), GameboardConstants.WALL_TILE_ID, Vector2(0,0))
