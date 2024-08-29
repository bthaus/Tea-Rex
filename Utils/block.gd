extends GameObjectCounted

class_name Block

enum BlockShape {TINY = 1, SMALL = 2, ARROW = 3, O = 4, I = 5, S = 6, Z = 7, L = 8, J = 9, T = 10, C = 11, CROSS = 12}

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
