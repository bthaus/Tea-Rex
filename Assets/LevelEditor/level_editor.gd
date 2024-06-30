extends Node2D


func _ready():
	$Board.tile_set.tile_size = Vector2(Stats.block_size, Stats.block_size)
	#var atlas: TileSetAtlasSource = $Board.tile_set.get_source(0)
	#$HUD/Sprite2D.texture = atlas.texture
	
func _input(event):
	var board_pos = $Board.local_to_map(get_global_mouse_position())
	if event.is_action_released("left_click"):
		$Board.set_cell(GameboardConstants.BLOCK_LAYER, board_pos, GameboardConstants.WALL_TILE_ID, Vector2(0,0))
	elif event.is_action_released("right_click"):
		$Board.set_cell(GameboardConstants.BLOCK_LAYER, board_pos, -1, Vector2(0,0))
