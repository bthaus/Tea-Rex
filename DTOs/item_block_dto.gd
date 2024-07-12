extends BaseDTO

class_name ItemBlockDTO

var block_shape: Stats.BlockShape
var direction: int
var tile_id: int
var map_position: Vector2

func _init(block_shape: Stats.BlockShape = Stats.BlockShape.O, direction: int = 0, tile_id: int = -1, map_position: Vector2 = Vector2(-1, -1)):
	self.block_shape = block_shape
	self.direction = direction
	self.tile_id = tile_id
	self.map_position = map_position
