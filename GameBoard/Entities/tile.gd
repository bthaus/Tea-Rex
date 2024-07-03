extends GameObjectCounted
class_name Tile

var id: int
var layer: int
var x: int
var y: int

func _init(id: int, layer: int, x: int, y: int):
	self.id = id
	self.layer = layer
	self.x = x
	self.y = y
