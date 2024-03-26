extends Node


class_name Block
var pieces: Array

class Piece:
	var position: Vector2
	var color: Stats.TurretColor
	var level: int
	func _init(position: Vector2, color: Stats.TurretColor, level: int):
		self.position = position
		self.color = color
		self.level = level
