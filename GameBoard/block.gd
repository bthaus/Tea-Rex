extends GameObjectCounted

class_name Block
var pieces: Array
var shape;
var color;
var extension;
func _init(pieces: Array):
	self.pieces = pieces
	
func clone() -> Block:
	var cloned_pieces = []
	for piece in pieces:
		cloned_pieces.push_back(Block.Piece.new(piece.position, piece.color, piece.level, piece.extension))
	return Block.new(cloned_pieces)

class Piece extends Resource:
	var position: Vector2
	var color: Stats.TurretColor
	var level: int
	var extension: Stats.TurretExtension
	func _init(position: Vector2, color: Stats.TurretColor, level: int, extension: Stats.TurretExtension=Stats.TurretExtension.DEFAULT):
		self.position = position
		self.color = color
		self.level = level
		self.extension = extension
