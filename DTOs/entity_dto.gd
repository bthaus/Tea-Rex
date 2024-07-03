extends BaseDTO
class_name EntityDTO

var tile_id: int
var layer: int
var x: int
var y: int

func _init(tile_id: int=-1, layer: int=-1, x: int=-1, y: int=-1):
	self.tile_id = tile_id
	self.layer = layer
	self.x = x
	self.y = y
