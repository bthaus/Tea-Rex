extends GameObjectCounted

class_name Block

enum BlockShape {O = 1, I = 2, S = 3, Z = 4, L = 5, J = 6, T = 7, TINY = 8, SMALL = 9, ARROW = 10, CROSS = 11}

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
	var color: Turret.Hue
	var level: int
	var extension: Turret.Extension
	func _init(position: Vector2, color: Turret.Hue, level: int, extension: Turret.Extension=Turret.Extension.DEFAULT):
		self.position = position
		self.color = color
		self.level = level
		self.extension = extension
