extends BaseDTO
class_name PlayerBaseDTO

var x: int
var y: int

func _init(x: int, y: int):
	self.x = x
	self.y = y
	
func get_object():
	return PlayerBase.new(self.x, self.y)
