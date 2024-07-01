extends BaseDTO
class_name PlayerBaseDTO

var tile_id: int
var x: int
var y: int

func _init(tile_id: int, x: int, y: int):
	self.tile_id = tile_id
	self.x = x
	self.y = y
	
func get_object():
	return PlayerBase.new(self.tile_id, self.x, self.y)
