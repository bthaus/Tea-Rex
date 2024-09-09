extends Node2D

var gamestate: GameState
var board_paths = []
var final_scale = Vector2(0.25, 0.25)

func _ready():
	$Board.tile_set.tile_size = Vector2(GameboardConstants.TILE_SIZE, GameboardConstants.TILE_SIZE)

func set_map(map_dto: MapDTO):
	scale = Vector2(1, 1)
	_draw_border()
	gamestate = load("res://Game/simulation_scene.tscn").instantiate()
	gamestate.map_dto=map_dto
	add_child(gamestate)
	
	#Problem is that the path lines of the spawners are not at the correct position when scaling or repositioning.
	#To solve that, we retrieve the paths of the spawners, and memorize where they are at the (unscaled) map -> local to map.
	#Then, we scale everything down, and gather the new points using the previously saved points -> map to local.
	board_paths = []
	for spawner in gamestate.spawners:
		for path in Spawner.get_paths($Board, spawner):
			var positions = []
			for path_pos in path.path:
				positions.append($Board.local_to_map(path_pos))
			board_paths.append(Path.new(positions, path.color))
		spawner.hide() #Hides old lines
	
	scale = final_scale
	call_deferred("queue_redraw")

func _draw():
	for path in board_paths:
		for i in path.board_positions.size()-1:
			draw_line($Board.map_to_local(path.board_positions[i]), $Board.map_to_local(path.board_positions[i+1]), path.color, 1, true)


func _draw_border():
	for y in range(-1, GameboardConstants.BOARD_HEIGHT+1):
		$Board.set_cell(GameboardConstants.MapLayer.BLOCK_LAYER, Vector2(-1, y), GameboardConstants.WALL_TILE_ID, Vector2(0,0))
		$Board.set_cell(GameboardConstants.MapLayer.BLOCK_LAYER, Vector2(GameboardConstants.BOARD_WIDTH, y), GameboardConstants.WALL_TILE_ID, Vector2(0,0))

	for x in range(-1, GameboardConstants.BOARD_WIDTH+1):
		$Board.set_cell(GameboardConstants.MapLayer.BLOCK_LAYER, Vector2(x, -1), GameboardConstants.WALL_TILE_ID, Vector2(0,0))
		$Board.set_cell(GameboardConstants.MapLayer.BLOCK_LAYER, Vector2(x, GameboardConstants.BOARD_HEIGHT), GameboardConstants.WALL_TILE_ID, Vector2(0,0))

class Path:
	var color
	var board_positions = []
	func _init(board_positions, color):
		self.board_positions = board_positions
		self.color = color
