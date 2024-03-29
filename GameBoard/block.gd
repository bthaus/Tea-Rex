extends Node


class_name Block
var pieces: Array
func _init(pieces: Array):
	self.pieces = pieces
	
func clone() -> Block:
	var cloned_pieces = []
	for piece in pieces:
		cloned_pieces.push_back(Block.Piece.new(piece.position, piece.color, piece.level))
	return Block.new(cloned_pieces)

class Piece:
	var position: Vector2
	var color: Stats.TurretColor
	var level: int
	func _init(position: Vector2, color: Stats.TurretColor, level: int):
		self.position = position
		self.color = color
		self.level = level
