extends BaseDTO
class_name BlockCycleEntryDTO

var piece_positions = []

func _init(piece_positions: Array = []):
	self.piece_positions = piece_positions

func get_object():
	var pieces = []
	for pos in piece_positions:
		pieces.append(Block.Piece.new(Vector2(pos.x, pos.y), Turret.Hue.WHITE, 1))
	return Block.new(pieces)
