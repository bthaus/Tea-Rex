extends BaseDTO
class_name TileDTO

var id: int
var layer: int
var x: int
var y: int

func get_object():
	return Tile.new(id, layer, x, y)
