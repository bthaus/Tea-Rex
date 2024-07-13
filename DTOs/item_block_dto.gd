extends BaseDTO

class_name ItemBlockDTO

var color: Stats.TurretColor
var block_shape: Block.BlockShape
var rotation: int
var tile_id: int
var map_position: Vector2

func _init(color: Stats.TurretColor = Stats.TurretColor.BLUE, block_shape: Block.BlockShape = Block.BlockShape.O, rotation: int = 0, tile_id: int = -1, map_position: Vector2 = Vector2(-1, -1)):
	self.color = color
	self.block_shape = block_shape
	self.rotation = rotation
	self.tile_id = tile_id
	self.map_position = map_position
