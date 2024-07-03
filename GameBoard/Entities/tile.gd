extends GameObjectCounted
class_name Tile

var tile_id: int
var map_layer: int
var map_position: Vector2

func _init(tile_id: int, map_layer: int, map_position: Vector2):
	self.tile_id = tile_id
	self.map_layer = map_layer
	self.map_position = map_position
	
func place_on_board(board: TileMap):
	board.set_cell(map_layer, map_position, tile_id, Vector2(0, 0))
