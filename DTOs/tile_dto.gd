extends BaseDTO
class_name TileDTO

var id: int
var layer: int
var x: int
var y: int

func _init(id: int=-1, layer: int=-1, x: int=-1, y: int=-1):
	self.id = id
	self.layer = layer
	self.x = x
	self.y = y

func get_object():
	return Tile.new(id, layer, x, y)
