extends Control
var board: TileMap
var game_state: GameState

const BLOCK_LAYER = 0
const GROUND_LAYER = 1
const EMPTY_TILE_ID = 6
const VIEW_RANGE = 50
func _process(delta):
	$TileMap.clear_layer(BLOCK_LAYER)
	for child in get_parent().get_parent().get_parent().get_parent().get_children():
		if child is GameBoard:
			board = child.get_node("Board")
			game_state = child.gameState
			break
			
	if board == null: return
	
	var camera_position = board.local_to_map(game_state.getCamera().position)
	for row in range(camera_position.y - VIEW_RANGE/2, camera_position.y + VIEW_RANGE/2):
		for col in range(-Stats.board_cave_deepness.to-1, game_state.board_width+Stats.board_cave_deepness.to):
			var normalized_row = row - (camera_position.y - VIEW_RANGE/2)
			var id_block = board.get_cell_source_id(BLOCK_LAYER, Vector2(col, row))
			var id_ground = board.get_cell_source_id(GROUND_LAYER, Vector2(col, row))
			$TileMap.set_cell(BLOCK_LAYER, Vector2(col, normalized_row), id_block, Vector2(0,0))
			if id_ground != -1 and id_ground != EMPTY_TILE_ID:
				$TileMap.set_cell(BLOCK_LAYER, Vector2(col, normalized_row), id_ground, Vector2(0,0))
