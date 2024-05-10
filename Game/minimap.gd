extends Control
var board: TileMap
var background: TileMap
var game_state: GameState

const BLOCK_LAYER = 0
const GROUND_LAYER = 1
const EMPTY_TILE_ID = 6
const BACKGROUND_TILE_ID = 3
const VIEW_RANGE = 50

func _ready():
	$Board.tile_set.tile_size = Vector2(Stats.block_size, Stats.block_size)
	$Background.tile_set.tile_size = Vector2(Stats.block_size, Stats.block_size)

func _process(delta):
	$Board.clear_layer(BLOCK_LAYER)
	$Background.clear_layer(0)
	for child in get_parent().get_parent().get_parent().get_parent().get_children():
		if child is GameBoard:
			board = child.get_node("Board")
			background = child.get_node("Background")
			game_state = child.gameState
			break
			
	if board == null or background == null: return
	
	var camera_position = board.local_to_map(game_state.getCamera().position)
	for row in range(camera_position.y - VIEW_RANGE/2, camera_position.y + VIEW_RANGE/2):
		for col in range(-Stats.board_cave_deepness.to-1, game_state.board_width+Stats.board_cave_deepness.to):
			var normalized_row = row - (camera_position.y - VIEW_RANGE/2)
			var board_id_block = board.get_cell_source_id(BLOCK_LAYER, Vector2(col, row))
			var board_id_ground = board.get_cell_source_id(GROUND_LAYER, Vector2(col, row))
			$Board.set_cell(BLOCK_LAYER, Vector2(col, normalized_row), board_id_block, Vector2(0,0))
			if board_id_ground != -1 and board_id_ground != EMPTY_TILE_ID:
				$Board.set_cell(BLOCK_LAYER, Vector2(col, normalized_row), board_id_ground, Vector2(0,0))
			var background_id = background.get_cell_source_id(0, Vector2(col, row))
			if background_id == BACKGROUND_TILE_ID:
				$Background.set_cell(BLOCK_LAYER, Vector2(col, normalized_row), BACKGROUND_TILE_ID, Vector2(0,0))
