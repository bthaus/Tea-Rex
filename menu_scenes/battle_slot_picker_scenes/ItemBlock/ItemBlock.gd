extends Node

class_name ItemBlock

var pieces: Array
var map_position: Vector2

func _init(pieces: Array = [], map_position: Vector2 = Vector2(0, 0)):
	self.pieces = pieces
	self.map_position = map_position
	
class Piece extends Node:
	var position: Vector2
	var tile_id: int
	
	func _init(position: Vector2, tile_id: int):
		self.position = position
		self.tile_id = tile_id
