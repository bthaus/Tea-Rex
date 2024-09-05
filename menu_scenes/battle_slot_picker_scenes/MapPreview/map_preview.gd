extends Node2D

func _ready():
	$Board.tile_set.tile_size = Vector2(GameboardConstants.TILE_SIZE, GameboardConstants.TILE_SIZE)

func set_map(map_dto: MapDTO):
	_draw_border()
	#for entity:EntityDTO in map_dto.entities:
	#	entity.get_object().place_on_board($Board)
	#link_spawners_to_waves(map_dto)

func _draw_border():
	for y in range(-1, GameboardConstants.BOARD_HEIGHT+1):
		$Board.set_cell(GameboardConstants.MapLayer.BLOCK_LAYER, Vector2(-1, y), GameboardConstants.WALL_TILE_ID, Vector2(0,0))
		$Board.set_cell(GameboardConstants.MapLayer.BLOCK_LAYER, Vector2(GameboardConstants.BOARD_WIDTH, y), GameboardConstants.WALL_TILE_ID, Vector2(0,0))

	for x in range(-1, GameboardConstants.BOARD_WIDTH+1):
		$Board.set_cell(GameboardConstants.MapLayer.BLOCK_LAYER, Vector2(x, -1), GameboardConstants.WALL_TILE_ID, Vector2(0,0))
		$Board.set_cell(GameboardConstants.MapLayer.BLOCK_LAYER, Vector2(x, GameboardConstants.BOARD_HEIGHT), GameboardConstants.WALL_TILE_ID, Vector2(0,0))
