extends BaseDTO
class_name EntityDTO

var tile_id: int
var map_layer: int
var map_x: int
var map_y: int

func _init(tile_id: int=-1, map_layer: int=-1, map_x: int=-1, map_y: int=-1):
	self.tile_id = tile_id
	self.map_layer = map_layer
	self.map_x = map_x
	self.map_y = map_y
